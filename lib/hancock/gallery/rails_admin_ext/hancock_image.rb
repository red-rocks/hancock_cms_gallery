require 'ack_rails_admin_jcrop'

module RailsAdmin
  module Config
    module Fields
      module Types
        class HancockImage < RailsAdmin::Config::Fields::Types::Jcrop
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option(:partial) do
            :form_hancock_image
          end

          register_instance_option :process_watermark_toggler_method do
            (!svg? and "process_watermark_#{name}")
          end
          register_instance_option :perform_autocrop_method do
            "#{name}_autocropped" if bindings and bindings[:object] and bindings[:object].respond_to?("#{name}_autocropped")
          end
          register_instance_option :perform_autocrop_default do
            true
          end

          register_instance_option :process_watermark_default do
            (!svg? and true)
          end

          register_instance_option :show_urls do
            false
          end

          register_instance_option :process_watermark_toggler do
            # bindings[:object].send(name).processors.include?(:watermark) and bindings[:object].respond_to?(process_watermark_toggler_method)
            (!svg? and bindings[:object].respond_to?(process_watermark_toggler_method))
          end


          register_instance_option :remote_url_method do
            "#{name}_remote_url"
          end


          register_instance_option :allowed_methods do
            ret = [method_name, delete_method, cache_method, perform_autocrop_method, remote_url_method]
            if true or process_watermark_toggler # temporary fix for nested params
              ret << process_watermark_toggler_method
            end
            ret.compact
          end

          register_instance_option :help do
            "SVG не изменяется. #{(required? ? I18n.translate('admin.form.required') : I18n.translate('admin.form.optional')) + '. '}"
          end

          register_instance_option :jcrop_options do
            "#{name}_jcrop_options".to_sym
          end

          register_instance_option :svg? do
            resource_url and (url = resource_url.to_s) and url.split('.').last =~ /svg/i
          end
          register_instance_option :thumb_method do
            if svg?
              :original
            else
              if bindings and bindings[:object] and bindings[:object].send(name)
                @thumb_method ||= ((styles = bindings[:object].send(name).styles.keys).find{|k| k.in?([:thumb, :thumbnail, 'thumb', 'thumbnail'])} || styles.first.to_s)
              else
                :original
              end
            end
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
