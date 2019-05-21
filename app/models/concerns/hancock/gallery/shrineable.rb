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
      
      include attachment_class.new(name)
      field "#{name}_data", type: Hash
      
      attacher = "#{name}_attacher"
      
      class_eval <<-RUBY
        def #{name}?
          !#{name}.blank?
        end
        def reprocess_#{name}!
          file = (#{name}.is_a?(Hash) ? #{name}[:original] : #{name})
          if #{attacher}.stored?
            self.update!(#{name}: file)
          else
            if #{attacher}.cached?
              #{attacher}.store!(#{name})
              self.save
            end
          end
        end
        def reprocess_#{name}
          file = (#{name}.is_a?(Hash) ? #{name}[:original] : #{name})
          if #{attacher}.stored?
            self.assign(#{name}: file)
          else
            if #{attacher}.cached?
              #{attacher}.store!(#{name})
            end
          end
        end
        def #{name}_updated_at
          #{name}.timestamp
        end
      RUBY
      
    end
    
  end

end
