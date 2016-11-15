module Hancock::Gallery
  module Models
    module EmbeddedImage
      if Hancock::Gallery.mongoid?
        extend ActiveSupport::Concern

        include Hancock::Gallery::Paperclipable
        include Hancock::Gallery::AutoCrop
        # if Hancock::Gallery.config.watermark_support
        #   include Hancock::Gallery::Watermarkable
        # end

        include Hancock::Gallery.orm_specific('EmbeddedImage')

        included do
          set_default_auto_crop_params_for(:image)
          hancock_cms_attached_file(:image)
          # if Hancock::Gallery.config.watermark_support
          #   paperclip_with_watermark(:image)
          # else
          #   hancock_cms_attached_file(:image)
          # end
        end

      end
    end
  end
end
