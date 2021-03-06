require "rails_admin_json_editor/version"

module RailsAdminJsonEditor
  class Engine < Rails::Engine
  end
end

require 'rails_admin/config/fields/types/text'

module RailsAdmin
  module Config
    module Fields
      module Types
        class JsonEditor < RailsAdmin::Config::Fields::Types::Text
          def self.parse_model_name m
            m.is_a?(::String) ? m : m.name.gsub("::", "___")
          end

          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types.register(self)

          register_instance_option :render do
            bindings[:view].render partial: "rails_admin_json_editor/main/form_json_editor", locals: {field: self, form: bindings[:form]}
          end

          register_instance_option :models do
            @models
          end

          def schema
            @models = []
            yield if block_given?
          end

          def orderable(o = nil)
            if o.nil? then return @orderable else @orderable = o end
          end

          def guids(o = nil)
            if o.nil? then return @guids else @guids = o end
          end

          def model(m)
            model = Model.new(m)

            yield(model) if block_given?

            @models << model
          end

          class Model
            attr_accessor :name, :fields
            attr_accessor :label, :help
            attr_accessor :hide_in_root

            def initialize(model)
              @name = JsonEditor.parse_model_name(model)
              @fields = []
              @label = @name.demodulize.humanize
            end

            def field(name, type, options = {})
              field = Field.new(name, type, options)

              yield(field) if block_given?

              @fields << field
            end

            def label(s = nil)
              if s.nil? then return @label else @label = s end
            end

            def help(s = nil)
              if s.nil? then return @help else @help = s end
            end

            def hide_in_root(b = nil)
              if b.nil? then return @hide_in_root else @hide_in_root = b end
            end
          end

          class Field
            attr_accessor :name,
                          :type

            attr_accessor :label,
                          :help,
                          :css_class

            attr_accessor :picker_model_name,
                          :picker_preview_field,
                          :picker_preview_image_field

            attr_accessor :list_model_names,
                          :list_max_length

            attr_accessor :enum_options

            def initialize(name, type, options = {})
              @name = name
              @type = type
              @label = name.to_s.humanize
            end

            def label(s = nil)
              if s.nil? then return @label else @label = s end
            end

            def help(s = nil)
              if s.nil? then return @help else @help = s end
            end

            def css_class(s = nil)
              if s.nil? then return @css_class else @css_class = s end
            end

            def picker(options)
              @picker_model_name = options[:model].name
              @picker_preview_field = options[:preview_field]
              @picker_preview_image_field = options[:preview_image_field]
            end

            def list(models, options = {})
              @list_model_names = Array(models).map { |m| JsonEditor.parse_model_name(m) }
              @list_max_length = options[:max_length]
            end

            def enum(options)
              @enum_options = options
            end
          end
        end
      end
    end
  end
end
