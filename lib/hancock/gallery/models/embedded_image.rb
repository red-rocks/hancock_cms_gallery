module Hancock::Gallery
  module Models
    module EmbeddedImage
      if Hancock::Gallery.mongoid?
        extend ActiveSupport::Concern

        # if defined?(Paperclip)
        #   include Hancock::Gallery::Paperclipable
        # elsif defined?(Shrine)
        #   include Hancock::Gallery::Shrineable
        # end
        
        # if Hancock::Gallery.config.watermark_support
        #   include Hancock::Gallery::Watermarkable
        # end

        include Hancock::Gallery.orm_specific('EmbeddedImage')

        included do
          include Hancock::Gallery::Uploadable
          
          # set_default_auto_crop_params_for(:image)
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
