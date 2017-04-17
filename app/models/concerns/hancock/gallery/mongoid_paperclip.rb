if Hancock.mongoid?
  module Hancock::Gallery::MongoidPaperclip
    extend ActiveSupport::Concern

    included do
      include ::Mongoid::Paperclip
    end

    module ClassMethods
      def hancock_cms_mongoid_attached_file(name, opts = {})
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
          cattr_accessor "#{name}_default_processors".to_sym
          instance_eval <<-RUBY
            self.#{name}_default_processors = []
            #{name}_default_processors << :rails_admin_jcropper
            if defined?(::PaperclipOptimizer)
              self.#{name}_default_processors << :paperclip_optimizer
              self.#{name}_default_processors.flatten!
              self.#{name}_default_processors.uniq!
            end
          RUBY
          unless opts[:processors].is_a?(Proc)
            opts[:processors] ||= []
            opts[:processors] << :rails_admin_jcropper
            if defined?(::PaperclipOptimizer)
              opts[:processors] << :paperclip_optimizer
              opts[:processors].flatten!
              opts[:processors].uniq!
            end
          end

          opts[:convert_options] = Hancock::Gallery.config.default_convert_options if opts[:convert_options].blank?

          if opts[:styles].blank?
            styles_method_name = "#{name}_styles"
            opts[:styles] = lambda { |attachment| attachment.instance.send(styles_method_name) }
          end

          set_default_auto_crop_params_for name
        end

        has_mongoid_attached_file name, opts
        # validates_attachment name, content_type: content_type unless content_type.blank?
        validates_attachment_content_type name, content_type: /\Aimage\/.*\Z/ if is_image

        class_eval <<-RUBY
          def #{name}_file_name=(val)
            return self[:#{name}_file_name] = ""  if val == ""
            return self[:#{name}_file_name] = nil if val == nil
            val = val.to_s
            extension = File.extname(val)[1..-1]
            if extension.blank?
              mime_type = MIME::Types[self.#{name}.content_type].first
              extension = mime_type.extensions.first if mime_type
              val = [val, extension].join(".") unless extension.blank?
            end
            file_name = val[0..val.size-extension.size-1]
            self[:#{name}_file_name] = "\#{file_name.filename_to_slug}.\#{extension.filename_to_slug}"
          end

          def #{name}_svg?
            # !!(#{name}_content_type =~ /svg/)
            #{name}.svg?
          end

          def #{name}_url(style=:original, opts = {})
            if #{name}_svg?
              #{name}.url
            else
              #{name}.url(style, opts)
            end
          end

          def reprocess_#{name}
            return if self.#{name}.blank?
            self.#{name}.reprocess! if File.exists?(self.#{name}.path)
          end

          def self.reprocess_all_#{name.to_s.pluralize}
            self.all.map(&:reprocess_#{name})
          end
        RUBY
        if defined?(::PaperclipOptimizer)
          class_eval <<-RUBY
            before_#{name}_post_process do
              p_o = self.#{name}.processors.delete :paperclip_optimizer
              self.#{name}.processors << p_o if p_o
              true
            end
          RUBY
        end
        jcrop_options ||= {}
        if jcrop_options
          class_eval <<-RUBY
            def #{name}_jcrop_options
              #{jcrop_options}
            end
          RUBY
        end
        if styles_method_name
          class_eval <<-RUBY
            def #{styles_method_name}
              {
                thumb: '128x128'
              }
            end
          RUBY
        end

      end


      def paperclip_style_aliases_for(name, opts = {})
        name = name.to_sym
        _styles = opts[:styles]
        if _styles.nil?
          if self.respond_to?("#{name}_styles")
            _styles = self.send("#{name}_styles")
          elsif (_obj = self.new).respond_to?("#{name}_styles")
            _styles = _obj.send("#{name}_styles")
          end
        end
        _styles = _styles.keys if _styles.is_a?(Hash)
        return if _styles.blank?
        _styles.each do |_style|
          class_eval <<-RUBY
            def #{name}_url_#{_style}
              #{name}.url(:#{_style})
            end
          RUBY
        end

      end

    end
  end
end
