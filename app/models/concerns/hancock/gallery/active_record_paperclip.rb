if Hancock.active_record?
  module Hancock::Gallery::ActiveRecordPaperclip
    extend ActiveSupport::Concern
    
    included do
      include ::Paperclip
    end

    module ClassMethods
      def hancock_cms_active_record_attached_file(name, opts = {})
        name = name.to_sym
        is_image = true
        styles_method_name = nil
        unless opts.blank?
          content_type = opts.delete(:content_type)
          jcrop_options = opts.delete(:jcrop_options)
          is_image = opts.delete(:is_image)
          is_image = true if is_image.nil?
        end

        if is_image
          if defined?(::PaperclipOptimizer)
            opts[:processors] ||= []
            opts[:processors] << :paperclip_optimizer
            opts[:processors].flatten!
            opts[:processors].uniq!
          end

          opts[:convert_options] = {all: "-quality 75 -strip"} if opts[:convert_options].blank?

          if opts[:styles].blank?
            styles_method_name = "#{name}_styles"
            opts[:styles] = lambda { |attachment| attachment.instance.send(styles_method_name) }
          end

          set_default_auto_crop_params_for

        end

        has_attached_file name, opts
        # validates_attachment name, content_type: content_type unless content_type.blank?
        validates_attachment_content_type name, content_type: /\Aimage\/.*\Z/ if is_image

        class_eval <<-EVAL
          def #{name}_file_name=(val)
            return self[:#{name}_file_name] = ""  if val == ""
            return self[:#{name}_file_name] = nil if val == nil
            val = val.to_s
            extension = File.extname(val)[1..-1]
            file_name = val[0..val.size-extension.size-1]
            self[:#{name}_file_name] = "\#{file_name.filename_to_slug}.\#{extension.filename_to_slug}"
          end

          def #{name}_svg?
            #{name}_content_type =~ /svg/
          end

          def #{name}_url(opts)
            if #{name}_svg?
              #{name}.url
            else
              #{name}.url(opts)
            end
          end
        EVAL
        if defined?(::PaperclipOptimizer)
          class_eval <<-EVAL
            before_#{name}_post_process do
              p_o = self.#{name}.processors.delete :paperclip_optimizer
              self.#{name}.processors << p_o if p_o
              true
            end
          EVAL
        end
        jcrop_options ||= {}
        if jcrop_options
          class_eval <<-EVAL
            def #{name}_jcrop_options
              #{jcrop_options}
            end
          EVAL
        end
        if styles_method_name
          class_eval <<-EVAL
            def #{styles_method_name}
              {
                thumb: '128x128'
              }
            end
          EVAL
        end

      end
    end
  end
end
