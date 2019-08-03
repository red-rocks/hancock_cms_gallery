module Hancock::Gallery::Shrineable
  extend ActiveSupport::Concern

  # include Hancock::Gallery::AutoCrop

  module ClassMethods
    def hancock_cms_attached_file(name, opts = {})
      add_hancock_shrine_uploader(name, opts)
    end


    def add_hancock_shrine_uploader(name, opts = {})
      uploader_class = opts.delete(:uploader_class) || ("#{self.to_s.camelize}#{name.to_s.camelize}Uploader").constantize
      attachment_class = uploader_class::Attachment
      unless opts.blank?
        crop_options = opts.delete(:crop_options)
        is_image = opts.delete(:is_image)
        is_image = true if is_image.nil?
      end
      
      include attachment_class.new(name)
      field "#{name}_data", type: Hash
      
      attacher = "#{name}_attacher"
        
      
      class_eval <<-RUBY
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
          #{name}.timestamp
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

end
