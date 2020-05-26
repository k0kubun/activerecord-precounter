module ActiveRecord
  module Precountable
    class NotPrecountedError < StandardError
    end

    def precounts(*association_names)
      association_names.each do |association_name|
        var_name = "#{association_name}_count"
        instance_var_name = "@#{var_name}"

        attr_writer(var_name)
        define_method(var_name) do
          count = instance_variable_get(instance_var_name)
          raise NotPrecountedError.new("`#{association_name}' not precounted") unless count
          count
        end
      end
    end
  end
end
