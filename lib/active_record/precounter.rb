require 'active_record/precounter/version'

module ActiveRecord
  class Precounter
    class MissingInverseOf < StandardError; end

    # @param [ActiveRecord::Relation] relation - Parent resources relation.
    def initialize(relation)
      @relation = relation
    end

    # @param [Array<String,Symbol>] association_names - Eager loaded association names. e.g. `[:users, :likes]`
    # @return [Array<ActiveRecord::Base>]
    def precount(*association_names)
      # Allow single record instances as well as relations to be passed.
      # The splat here will return an array of the single record if it's
      # not a relation or otherwise return the records themselves via #to_a.
      records = *@relation
      return records if records.empty?

      # We need to get the relation's active class, which is the class itself
      # in the case of a single record.
      klass = @relation.respond_to?(:klass) ? @relation.klass : @relation.class

      association_names.each do |association_name|
        association_name = association_name.to_s
        reflection = klass.reflections.fetch(association_name)

        if reflection.inverse_of.nil?
          raise MissingInverseOf.new(
            "`#{reflection.klass}` does not have inverse of `#{klass}##{reflection.name}`. "\
            "Probably missing to call `#{reflection.klass}.belongs_to #{klass.name.underscore.to_sym.inspect}`?"
          )
        end

        primary_key = reflection.inverse_of.association_primary_key.to_sym

        count_by_id = if reflection.has_scope?
                        # ActiveRecord 5.0 unscopes #scope_for argument, so adding #where outside that:
                        # https://github.com/rails/rails/blob/v5.0.7/activerecord/lib/active_record/reflection.rb#L314-L316
                        reflection.scope_for(reflection.klass.unscoped).where(reflection.inverse_of.name => records.map(&primary_key)).group(
                          reflection.inverse_of.foreign_key
                        ).count
                      else
                        reflection.klass.where(reflection.inverse_of.name => records.map(&primary_key)).group(
                          reflection.inverse_of.foreign_key
                        ).count
                      end

        writer = define_count_accessor(records.first, association_name)
        records.each do |record|
          record.public_send(writer, count_by_id.fetch(record.public_send(primary_key), 0))
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
