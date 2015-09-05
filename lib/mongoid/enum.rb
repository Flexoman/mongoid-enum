require 'mongoid/enum/version'
require 'mongoid/enum/validators/multiple_validator'

module Mongoid
  # Mongoid Enum
  module Enum
    extend ActiveSupport::Concern
    #
    # Class Methods
    #
    # class Model
    #   include Mongoid::Enum
    #
    #   enum :status, in: %i( waiting approved dismissed )
    #
    module ClassMethods
      #
      # Main class method
      #
      def enum(field_name, values, options = {})
        options = default_options.merge(options)

        set_values_constant field_name, values

        create_field field_name, options, values
        create_i18n_helper field_name, options
        create_values_helper field_name, options

        create_validations field_name, values, options
        define_value_scopes_and_accessors field_name, values, options
        return unless options[:multiple]
        define_array_field_writer field_name
      end

      private

      def default_options
        {
          multiple: false,
          required: true,
          validate: true
        }
      end

      def set_values_constant(name, values)
        const_name = name.to_s.upcase
        const_set const_name, values
      end

      def create_field(field_name, options, values)
        type = options[:multiple] && Array || Symbol
        default = \
        if options.key?(:default)
          options[:default]
        else
          options[:multiple] ? [] : values.first
        end
        field field_name, type: type, default: default
      end

      def define_array_field_writer(field_name)
        define_method("#{field_name}=") do |vals|
          write_attribute(field_name, Array(vals).compact.map(&:to_sym))
        end
      end

      def create_validations(field_name, values, options)
        if options[:multiple] && options[:validate]
          validates field_name, :'mongoid/enum/validators/multiple' => {
            in: values.map(&:to_sym),
            allow_nil: !options[:required]
          }
        elsif validate
          validates field_name,
                    inclusion: { in: values },
                    allow_nil: !options[:required]
        end
      end

      def create_i18n_helper(field_name, options)
        return if options[:i18n].is_a?(FalseClass)
        if options[:multiple]
          define_method("#{field_name}_i18n") do
            return if self[field_name].blank?
            self[field_name].map do |k|
              I18n.translate("mongoid.enums.#{model_name.to_s.underscore}."\
                             "#{field_name}.#{k}")
            end
          end
        else
          define_method("#{field_name}_i18n") do
            return if self[field_name].blank?
            I18n.translate("mongoid.enums.#{model_name.to_s.underscore}."\
                         "#{field_name}.#{self[field_name]}")
          end
        end
      end

      def create_values_helper(field_name, options)
        return if options[:i18n].is_a?(FalseClass)
        define_singleton_method("#{field_name}_values") do
          I18n.translate("mongoid.enums.#{model_name.to_s.underscore}."\
                         "#{field_name}").map {  |k, v| [v, k] }
        end
      end

      def define_value_scopes_and_accessors(field_name, values, options)
        values.each do |value|
          unless options[:scope].is_a?(FalseClass)
            scope value, -> { where(field_name => value) }
          end
          next if options[:accessor].is_a?(FalseClass)
          if options[:multiple]
            define_array_accessor(field_name, value)
          else
            define_string_accessor(field_name, value)
          end
        end
      end

      def define_array_accessor(field_name, value)
        class_eval "def #{value}?() self.#{field_name}.include?(:#{value}) end"
        class_eval "def #{value}!() update_attributes! :#{field_name} => (self.#{field_name} || []) + [:#{value}] end"
      end

      def define_string_accessor(field_name, value)
        class_eval "def #{value}?() self.#{field_name} == :#{value} end"
        define_method("#{value}!") do
          update_attributes! :"#{field_name}" => :"#{value}"
        end
      end
    end
  end
end
