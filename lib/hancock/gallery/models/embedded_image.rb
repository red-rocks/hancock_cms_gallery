module Hancock::Gallery
  module Models
    module EmbeddedImage
      if Hancock::Gallery.mongoid?
        extend ActiveSupport::Concern
        include Hancock::Gallery::Paperclipable

        include Hancock::Gallery.orm_specific('EmbeddedImage')

        included do
          hancock_cms_attached_file(:image)

          after_save do
            auto_rails_admin_jcrop(:image)
          end
        end
        
      end
    end
  end
end
