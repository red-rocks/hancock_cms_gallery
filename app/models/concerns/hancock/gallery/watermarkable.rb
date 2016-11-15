module Hancock::Gallery::Watermarkable
  extend ActiveSupport::Concern

  module ClassMethods
    def paperclip_with_watermark(field = :image, original_image_class_name = "Hancock::Gallery::OriginalImage")

      attr_accessor "#{field}_autocropped".to_sym

      hancock_cms_attached_file field, processors: [:watermark]
      # field "original_#{field}", type: BSON::Binary
      has_one "original_#{field}_data", as: :originable, class_name: original_image_class_name

      class_eval %{
        after_save :#{field}_auto_rails_admin_jcrop
        def #{field}_auto_rails_admin_jcrop
          return if self.#{field}.blank? or !self.#{field}_updated_at_changed? or self.#{field}_autocropped
          self.#{field}_autocropped = true

          if File.exists?(self.#{field}.path)
            auto_rails_admin_jcrop(#{field.to_sym})

          elsif (_data = self.original_#{field})
            _old_filename = self.#{field}_file_name
            if _data
              _data = _data.data
              _temp = Tempfile.new(_old_filename)
              _temp.binmode
              _temp.write _data
              File.unlink(self.#{field}.path) if File.symlink?(self.#{field}.path)
              File.symlink(_temp.path, self.#{field}.path)
              # self.#{field} = _temp
              # self.#{field}.instance_write(:file_name, "\#{SecureRandom.hex}\#{File.extname(_old_filename)}")
              self.class.skip_callback(:save, :after, "original_#{field}_to_db".to_sym)
              auto_rails_admin_jcrop(#{field.to_sym})
              self.class.set_callback(:save, :after, "original_#{field}_to_db".to_sym)
              _temp.unlink
            end
          end
        end

        before_#{field}_post_process do
          p_o = self.#{field}.processors.delete :paperclip_optimizer
          # if p_o
          #   _processors = self.#{field}.processors.dup
          #   self.#{field}.processors.clear
          #   self.#{field}.processors = [:thumbnail, p_o]
          #   _processors.each do |p|
          #     self.#{field}.processors << p
          #   end
          # end

          p_w = self.#{field}.processors.delete :watermark
          self.#{field}.processors << p_w if p_w

          true
        end

        def original_#{field}
          original_#{field}_data.original if original_#{field}_data
        end
        def original_#{field}_base64
          _data = Base64.encode64(self.original_#{field}_data.original.data)
          _content_type = self.#{field}_content_type
          "data:\#{_content_type};base64,\#{_data}"
        end

        after_save :original_#{field}_to_db
        def original_#{field}_to_db
          if self.#{field}_file_name
            if File.exists?(self.#{field}.path)
              _original = self.original_#{field}_data
              unless _original
                _original = #{original_image_class_name}.new
                _original.originable = self
              end
              _original.original = BSON::Binary.new(File.binread(self.#{field}.path))
              if _original.save
                File.unlink(self.#{field}.path)
              end
            end
          end
        end

        def reprocess_#{field}
          return if self.#{field}.blank?

          if File.exists?(self.#{field}.path)
            self.#{field}.reprocess!
          elsif (_data = self.original_#{field})
            _old_filename = self.#{field}_file_name
            if _data
              _data = _data.data
              _temp = Tempfile.new(_old_filename)
              _temp.binmode
              _temp.write _data
              File.unlink(self.#{field}.path) if File.symlink?(self.#{field}.path)
              File.symlink(_temp.path, self.#{field}.path)
              self.#{field} = _temp
              self.#{field}.instance_write(:file_name, "\#{SecureRandom.hex}\#{File.extname(_old_filename)}")
              self.class.skip_callback(:save, :after, "original_#{field}_to_db".to_sym)
              self.#{field}.reprocess!
              self.class.set_callback(:save, :after, "original_#{field}_to_db".to_sym)
              _temp.unlink
              self.save
            end
          end
        end
      }
    end
  end

end
