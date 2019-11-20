module Hancock::Gallery::Shrineable
  extend ActiveSupport::Concern

  # include Hancock::Gallery::AutoCrop

  class_methods do
    def hancock_cms_attached_file(name, opts = {})
      add_hancock_shrine_uploader(name, opts)
    end


    def add_hancock_shrine_uploader(name, opts = {})
      unless opts.blank?
        crop_options = opts.delete(:crop_options)
        is_image = opts.delete(:is_image)
        is_image = true if is_image.nil?
      end
      # uploader_class = opts.delete(:uploader_class) || ("#{self.to_s.camelize}#{name.to_s.camelize}Uploader").constantize
      uploader_class = if opts 
        if opts.has_key?(:uploader_class)
          opts.delete(:uploader_class)
        elsif opts.has_key?(:uploader_class_name)
          opts.delete(:uploader_class_name).safe_constantize
        end
      end
      # puts uploader_class.inspect
      uploader_class ||= get_uploader_class(name.to_s, is_image)
      return nil if uploader_class.nil? # TODO or maybe return

      attachment_class = uploader_class::Attachment
      
      include attachment_class.new(name, hancock_model: self, is_image: is_image)
      field "#{name}_data", type: Hash
      
      attacher = "#{name}_attacher"
      
      class_eval <<-RUBY
        def self.#{name}_is_image?; #{!!is_image}; end
        def #{name}_is_image?; self.class.#{name}_is_image?; end

        def remove_#{name}!
          if respond_to?(:remove_#{name}=)
            self.remove_#{name} = 1
            self.save
          end
        end
        def #{name}?
          !#{name}.blank?
        end
        def reprocess_#{name}!
          if #{attacher} and #{attacher}.respond_to?(:derivatives)
            #{attacher}.remove_derivatives
            return (#{name}_derivatives! and self.save!)
          end
          file = (#{name}.is_a?(Hash) ? #{name}[:original] : #{name})
          if #{attacher}.stored?
            self.update!(#{name}: file)
            # self.#{attacher}._promote(action: :store)
          else
            if #{attacher}.cached?
              #{attacher}.store!(#{name})
              self.save
            end
          end
        end
        def reprocess_#{name}
          puts 'reprocess_ #{name}'
          if #{attacher} and #{attacher}.respond_to?(:derivatives)
            #{attacher}.remove_derivatives
            return #{name}_derivatives!
          end
          
          file = (#{name}.is_a?(Hash) ? #{name}[:original] : #{name})
          if #{attacher}.stored?
            self.assign_attributes(#{name}: file)
            # self.update(#{name}: file)
            # self.#{attacher}._promote(action: :store)
          else
            if #{attacher}.cached?
              #{attacher}.store!(#{name})
            end
          end
        end
        def #{name}_updated_at
          (#{name} and #{name}.timestamp)
        end

        def get_#{name}(style = :original)
          (#{name} and #{name}[style])
        end
      RUBY

      styles_method_name = opts.delete(:styles_method_name)
      styles_method_name = "#{name}_styles" if styles_method_name.nil?
      if styles_method_name
        class_eval <<-RUBY
          def #{styles_method_name}
            {
              thumb: '128x128'
            }
          end
        RUBY

      end

      if is_image
        crop_options ||= {}
        if crop_options
          class_eval <<-RUBY
            def #{name}_crop_options
              #{crop_options}
            end
            alias_method :#{name}_jcrop_options, :#{name}_crop_options
          RUBY

        end
      end
      
    end

    def get_uploader_class(name, is_image)
      # puts 'def get_uploader_class_name(name)'
      # puts self.inspect
      # puts name.inspect
      uploader_class = "#{self.name.camelize}#{name.to_s.camelize}Uploader".safe_constantize
      # puts uploader_class.inspect
      
      if uploader_class
        uploader_class
      else
        _superclass = self.superclass
        if _superclass < Hancock::Gallery::Shrineable
          _superclass.get_uploader_class(name, is_image).safe_constantize rescue nil
        else
          (is_image ? HancockImageUploader : HancockUploader)
        end
      end
    end
    
  end

end
