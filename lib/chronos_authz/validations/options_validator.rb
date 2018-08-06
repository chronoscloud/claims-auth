module ChronosAuthz
  module Validations
    module OptionsValidator

      def self.included base
        base.extend OptionsValidatorClassMethods
      end    

      module OptionsValidatorClassMethods
        attr_accessor :required_options, :predefined_value_map

        def required(*options)
          self.required_options = options
        end

        def check_constraint(option, predefined_values = [], constraint_options = {})
          self.predefined_value_map ||= {}
          self.predefined_value_map[option] = { check_values: predefined_values, 
                                                constraint_options: constraint_options }
        end
      end

      def validate!
        return true if self.class.required_options.nil?

        # Validate required options
        self.class.required_options.each do |required_option|
          option_value = send(required_option)
          raise ChronosAuthz::Validations::ValidationError.new("Missing option #{required_option} in #{self.class}") if option_value.nil? or option_value.empty?
        end

        # Validate option values
        if !self.class.predefined_value_map.nil?
          self.class.predefined_value_map.each do |key, value|
            option_values = send(key)
            check_values = value[:check_values]

            if !option_values.is_a? Array
              option_values = [option_values]
            end

            if value[:constraint_options][:case_sensitive].nil? || !value[:constraint_options][:case_sensitive]
              option_values = option_values.map{|option_value| option_value.to_s.upcase }
              check_values = check_values.map{|check_value| check_value.to_s.upcase }
            end

            option_values.each do |option_value|
              next if value[:constraint_options][:allow_nil] && (option_value.nil? || option_value.empty?)
              raise ChronosAuthz::Validations::ValidationError.new("Invalid option value #{option_value} for #{key} in #{self.class}. Valid values are #{check_values}.") if !check_values.include?(option_value) 
            end
          end
        end

        self
      end
    end

  end
end