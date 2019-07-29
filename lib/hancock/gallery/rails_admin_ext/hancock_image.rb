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
            # (!svg? and "process_watermark_#{name}")
            # read below in :allowed_methods
            "process_watermark_#{name}"
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
            true
          end

          register_instance_option :process_watermark_toggler do
            # bindings[:object].send(name).processors.include?(:watermark) and bindings[:object].respond_to?(process_watermark_toggler_method)
            (!svg? and bindings[:object].respond_to?(process_watermark_toggler_method))
          end


          register_instance_option :remote_url_method do
            "#{name}_remote_url"
          end

          register_instance_option :delete_method do
            "remove_#{name}"
          end

          register_instance_option :allowed_methods do
            ret = [method_name, delete_method, cache_method, perform_autocrop_method, remote_url_method]
            # https://github.com/sferik/rails_admin/blob/b92a4d1a30b706d08df2aee4d0a59dad698a0552/app/controllers/rails_admin/main_controller.rb#L92-L105
            # bindings[:object] is not nested but parent, so resource_url had send wrong object
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

          register_instance_option :styles do
            if @styles.nil?
              @styles = []
              if value
                @styles = value.keys if value.is_a?(Hash)
                @styles = value.styles if styles.blank? and value.respond_to?(:styles)
              end
            end
            @styles
          end
          register_instance_option :thumb_method do
            if svg?
              :original
            else
              if bindings and bindings[:object] and bindings[:object].send(name)
                @thumb_method ||= (styles.find{|k| k.in?([:thumb, :thumbnail, 'thumb', 'thumbnail'])} || styles.first.to_s)
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
