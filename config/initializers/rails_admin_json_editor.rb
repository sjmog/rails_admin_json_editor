require 'rails_admin/config/fields/types/text'

module RailsAdmin
  module Config
    module Fields
      module Types
        class JsonEditor < RailsAdmin::Config::Fields::Types::Text
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types.register(self)

          register_instance_option :partial do
            :form_json_editor
          end

          register_instance_option :components do
            @components
          end

          def setup
            @components = []
            yield if block_given?
          end

          def component(type)
            component = Component.new(type)

            yield(component) if block_given?

            @components << component
          end

          class Component
            attr_accessor :type, :fields
            attr_accessor :label, :help

            def initialize(type)
              @type = type
              @fields = []
              @label = type
            end

            def field(name, type)
              field = Field.new(name, type)

              yield(field) if block_given?

              @fields << field
            end

            def label(s = nil)
              if s.nil? then return @label else @label = s end
            end

            def help(s = nil)
              if s.nil? then return @help else @help = s end
            end
          end

          class Field
            attr_accessor :name, :type
            attr_accessor :label, :help
            attr_accessor :picker_records

            def initialize(name, type)
              @name = name
              @type = type
              @label = name
            end

            def label(s = nil)
              if s.nil? then return @label else @label = s end
            end

            def help(s = nil)
              if s.nil? then return @help else @help = s end
            end

            def picker_records(a = nil)
              if a.nil? then return @picker_records else @picker_records = a end
            end
          end
        end
      end
    end
  end
end
