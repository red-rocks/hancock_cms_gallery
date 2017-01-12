require 'ack_rails_admin_jcrop'

module RailsAdmin
  module Config
    module Fields
      module Types
        class HancockImage < RailsAdmin::Config::Fields::Types::Jcrop
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option :process_watermark_toggler_method do
            "process_watermark_#{name}"
          end

          register_instance_option :process_watermark_default do
            true
          end

          register_instance_option :process_watermark_toggler do
            # bindings[:object].send(name).processors.include?(:watermark) and bindings[:object].respond_to?(process_watermark_toggler_method)
            bindings[:object].respond_to?(process_watermark_toggler_method)
          end


          register_instance_option :allowed_methods do
            if process_watermark_toggler
              [method_name, delete_method, cache_method, process_watermark_toggler_method].compact
            else
              [method_name, delete_method, cache_method].compact
            end
          end

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
