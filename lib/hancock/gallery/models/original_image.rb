module Hancock::Gallery
  module Models
    module OriginalImage
      extend ActiveSupport::Concern

      include Hancock::Model
      include Hancock::Gallery::Paperclipable
      include Hancock::Gallery.orm_specific('OriginalImage')

      included do
        if Hancock.rails4?
          belongs_to :originable, polymorphic: true
        else
          belongs_to :originable, polymorphic: true, optional: true
        end

        def from_db_to_fs
          unless self.original.blank?
            _paperclip_obj = Paperclip.io_adapters.for(self.original_as_base64)
            mime_type = MIME::Types[_paperclip_obj.content_type].first
            _paperclip_obj.original_filename = "#{_paperclip_obj.original_filename}.#{mime_type.extensions.first}" if mime_type
            self.image = _paperclip_obj
            self.original = nil
            return self
          end
          return false
        end
        def from_db_to_fs!
          self.from_db_to_fs and self.save
        end

        def relocate_original
          unless File.exists? self.image.path
            _path = self.image.path
            _old_file = Dir[File.dirname(self.image.path) + "/*#{File.extname(self.image.path)}"].first
            if _old_file
              return File.rename _old_file, _path
            end
            return nil
          end
          return false
        end
        def relocate_original!
          self.relocate_original and self.image.reprocess!
        end


        def original_as_base64(content_type = nil)
          _original = self.original
          if _original
            _data = Base64.encode64(_original.data)
            _content_type = content_type
          else
            _data = ''
            _content_type = content_type || 'jpg'
          end
          "data:#{_content_type};base64,#{_data}"
        end
        def original_as_image(content_type = nil)
          "<img src='#{original_as_base64(content_type)}'>".html_safe
        end

        # def self.admin_can_default_actions
        #   [:show, :read].freeze
        # end
        # def self.manager_can_default_actions
        #   [:show, :read].freeze
        # end
        def self.admin_cannot_actions
          [:new, :create, :edit, :update].freeze
        end
        def self.manager_cannot_actions
          [:new, :create, :edit, :update].freeze
        end

      end

    end
  end
end
