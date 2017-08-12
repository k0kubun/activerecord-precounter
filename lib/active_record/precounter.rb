require 'active_record/precounter/version'

module ActiveRecord
  class Precounter
    class MissingInverseOf < StandardError; end

    # @param [ActiveRecord::Relation] relation - Parent resources relation.
    # @param [Array<String,Symbol>] association_names - Eager loaded association names. e.g. `[:users, :likes]`
    def initialize(relation, *association_names)
      @relation = relation
      @association_names = association_names.map(&:to_s)
    end

    # @return [Array<ActiveRecord::Base>]
    def precount
      records = @relation.to_a
      return if records.empty?

      @association_names.each do |association_name|
        reflection = @relation.klass.reflections.fetch(association_name)
        if reflection.inverse_of.nil?
          raise MissingInverseOf.new(
            "`#{reflection.klass}` does not have inverse of `#{@relation.klass}##{reflection.name}`. "\
            "Probably missing to call `#{reflection.klass}.belongs_to #{@relation.name.underscore.to_sym.inspect}`?"
          )
        end

        count_by_id = reflection.klass.where(reflection.inverse_of.name => @relation).group(
          reflection.inverse_of.foreign_key
        ).count

        writer = define_count_accessor(records.first, association_name)
        records.each do |record|
          record.public_send(writer, count_by_id.fetch(record.id, 0))
        end
      end
      records
    end

    private

    # @param [ActiveRecord::Base] record
    # @param [String] association_name
    # @return [String] writer method name
    def define_count_accessor(record, association_name)
      reader_name = "#{association_name}_count"
      writer_name = "#{reader_name}="

      if !record.respond_to?(reader_name) && !record.respond_to?(writer_name)
        record.class.send(:attr_accessor, reader_name)
      end

      writer_name
    end
  end
end
