require 'ack_rails_admin_jcrop'

module RailsAdmin
  module Config
    module Fields
      module Types
        class HancockImage < RailsAdmin::Config::Fields::Types::Jcrop
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option :help do
            "SVG не изменяется."
          end

          register_instance_option :jcrop_options do
            "#{name}_jcrop_options".to_sym
          end

        end
      end
    end
  end
end

RailsAdmin::Config::Fields.register_factory do |parent, properties, fields|
  if (properties.respond_to?(:name) ? properties.name : properties[:name]) == :hancock_image
    fields << RailsAdmin::Config::Fields::Types::HancockImage.new(parent, :hancock_image, properties)
    true
  else
    false
  end
end