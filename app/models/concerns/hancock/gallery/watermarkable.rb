# module Hancock::Gallery::Watermarkable
#   extend ActiveSupport::Concern

#   module ClassMethods
#     def paperclip_with_watermark(field = :image, original_image_class_name = "Hancock::Gallery::OriginalImage", opts = {})
#       if field.is_a?(Hash)
#         field, original_image_class_name, opts =
#           field.delete(:field) || :image, field.delete(:original_image_class_name) || "Hancock::Gallery::OriginalImage", field
#       else
#         if original_image_class_name.is_a?(Hash)
#           original_image_class_name, opts =
#             original_image_class_name.delete(:original_image_class_name) || "Hancock::Gallery::OriginalImage", original_image_class_name
#         end
#       end
#       autocrop = (opts.key?(:autocrop) ? opts[:autocrop] : true)
#       attr_accessor "process_watermark_#{field}".to_sym

#       opts[:processors] ||= -> (instance) {
#         _processors = (instance.try("#{field}_default_processors") || []).dup
#         p_o = _processors.delete :paperclip_optimizer
#         if p_o
#           __processors = _processors.dup.uniq
#           _processors.clear
#           # _processors << :thumbnail
#           _processors << p_o
#           __processors.each do |p|
#             _processors << p
#           end
#         end

#         # p_w = _processors.delete :watermark
#         if ['1', 'true', 't', 'yes', 'y', true, 1, :true, :yes].include?(instance.try("process_watermark_#{field}"))
#           _processors << :watermark
#         end
#         _processors.uniq
#       }

#       hancock_cms_attached_file field, opts

#       # field "original_#{field}", type: BSON::Binary
#       has_one "original_#{field}_data", as: :originable, class_name: original_image_class_name, dependent: :destroy

#       if autocrop
#         autocrop_code = %{
#           self.#{field}_autocropped = false if self.#{field}_autocropped == "0"
#           return if self.#{field}.blank? or !self.#{field}_updated_at_changed? or self.#{field}_autocropped
#           self.#{field}_autocropped = true
#         }
#       else
#         autocrop_code = ""
#       end

#       class_eval %{
#         def #{field}_auto_rails_admin_jcrop
#           #{autocrop_code}
#           return if self.#{field}.path.nil?

#           if File.exists?(self.#{field}.path)
#             auto_rails_admin_jcrop(:#{field})

#           # original file in object`s original_image as file
#           elsif self.original_#{field}_data and !self.original_#{field}_data.image.blank?
#             _dir = File.dirname(self.#{field}.path)
#             FileUtils.mkdir_p(_dir) unless File.exists?(_dir)
#             File.unlink(self.#{field}.path) if File.symlink?(self.#{field}.path)
#             File.symlink(self.original_#{field}_data.image.path, self.#{field}.path)
#             self.class.skip_callback(:save, :after, "save_original_#{field}".to_sym)
#             self.#{field}.reprocess!
#             self.class.set_callback(:save, :after, "save_original_#{field}".to_sym)
#             File.unlink(self.#{field}.path)

#           elsif (_data = self.original_#{field})
#             _old_filename = self.#{field}_file_name
#             if _data
#               _data = _data.data
#               _temp = Tempfile.new(_old_filename)
#               _temp.binmode
#               _temp.write _data
#               _dir = File.dirname(self.#{field}.path)
#               FileUtils.mkdir_p(_dir) unless File.exists?(_dir)
#               File.unlink(self.#{field}.path) if File.symlink?(self.#{field}.path)
#               File.symlink(_temp.path, self.#{field}.path)
#               # self.#{field} = _temp
#               # self.#{field}.instance_write(:file_name, "\#{SecureRandom.hex}\#{File.extname(_old_filename)}")
#               self.class.skip_callback(:save, :after, "original_#{field}_to_db".to_sym)
#               auto_rails_admin_jcrop(:#{field})
#               self.class.set_callback(:save, :after, "original_#{field}_to_db".to_sym)
#               File.unlink(self.#{field}.path)
#               _temp.unlink
#             end
#           end
#         end

#         # before_#{field}_post_process do
#         #   p_o = self.#{field}.processors.delete :paperclip_optimizer
#         #   if p_o
#         #     _processors = self.#{field}.processors.dup
#         #     self.#{field}.processors.clear
#         #     # self.#{field}.processors << :thumbnail
#         #     self.#{field}.processors << p_o
#         #     _processors.each do |p|
#         #       self.#{field}.processors << p
#         #     end
#         #   end
#         #
#         #   p_w = self.#{field}.processors.delete :watermark
#         #   if p_w and self.process_watermark_#{field}
#         #     self.#{field}.processors << p_w
#         #   end
#         #   self.#{field}.processors.uniq!
#         #
#         #
#         #   true
#         # end

#         def original_#{field}
#           original_#{field}_data and original_#{field}_data.original
#         end
#         def original_#{field}_base64
#           original_#{field}_data and original_#{field}_data.original_as_base64(self.#{field}_content_type)
#         end
#         def original_#{field}_image
#           original_#{field}_data and original_#{field}_data.original_as_image(self.#{field}_content_type)
#         end

#         # after_save :original_#{field}_to_db
#         def original_#{field}_to_db
#           unless self.#{field}.blank?
#             if File.exists?(self.#{field}.path)
#               _original = self.original_#{field}_data
#               unless _original
#                 _original = #{original_image_class_name}.new
#                 _original.originable = self
#               end
#               _original.image = nil
#               _original.original = BSON::Binary.new(File.binread(self.#{field}.path))
#               if _original.save
#                 File.unlink(self.#{field}.path)
#               end
#             end
#           else
#             self.original_#{field}_data and self.original_#{field}_data.delete
#           end
#         end

#         after_save :save_original_#{field}
#         def save_original_#{field}
#           unless self.#{field}.blank?
#             if File.exists?(self.#{field}.path)
#               _original = self.original_#{field}_data
#               unless _original
#                 _original = #{original_image_class_name}.new
#                 _original.originable = self
#               end
#               _original.image = self.#{field}
#               _original.original = nil
#               if _original.save
#                 File.unlink(self.#{field}.path) if File.exists?(self.#{field}.path)
#               end
#             end
#           else
#             self.original_#{field}_data and self.original_#{field}_data.delete
#           end
#         end

#         def reprocess_#{field}_with_watermark
#           self.process_watermark_#{field} = true
#           self.reprocess_#{field}
#         end

#         def reprocess_#{field}
#           return if self.#{field}.blank?

#           # original file in object
#           if File.exists?(self.#{field}.path)
#             self.#{field}.reprocess!

#           # original file in object`s original_image as file
#           elsif self.original_#{field}_data and !self.original_#{field}_data.image.blank?
#             _dir = File.dirname(self.#{field}.path)
#             FileUtils.mkdir_p(_dir) unless File.exists?(_dir)
#             File.unlink(self.#{field}.path) if File.symlink?(self.#{field}.path)
#             File.symlink(self.original_#{field}_data.image.path, self.#{field}.path)
#             self.class.skip_callback(:save, :after, "save_original_#{field}".to_sym)
#             self.#{field}.reprocess!
#             self.class.set_callback(:save, :after, "save_original_#{field}".to_sym)
#             File.unlink(self.#{field}.path)

#           # original file in object`s original_image as db field
#           elsif (_data = self.original_#{field})
#             _old_filename = self.#{field}_file_name
#             if _data
#               _data = _data.data
#               _temp = Tempfile.new(_old_filename)
#               _temp.binmode
#               _temp.write _data
#               _dir = File.dirname(self.#{field}.path)
#               FileUtils.mkdir_p(_dir) unless File.exists?(_dir)
#               File.unlink(self.#{field}.path) if File.symlink?(self.#{field}.path)
#               File.symlink(_temp.path, self.#{field}.path)
#               # self.#{field} = _temp
#               # self.#{field}.instance_write(:file_name, "\#{SecureRandom.hex}\#{File.extname(_old_filename)}")
#               self.class.skip_callback(:save, :after, "original_#{field}_to_db".to_sym)
#               self.#{field}.reprocess!
#               self.class.set_callback(:save, :after, "original_#{field}_to_db".to_sym)
#               _temp.unlink
#               File.unlink(self.#{field}.path)
#               # self.save
#             end
#           end
#         end
#       }
#     end
#   end

# end
