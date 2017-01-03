module Hancock::Gallery
  module Models
    module Mongoid
      module OriginalImage
        extend ActiveSupport::Concern

        included do
          index({originable_id: 1, originable_type: 1}, {background: true})

          field :original, type: BSON::Binary

          hancock_cms_attached_file(:image, url: "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
                                            hash_data: ":class/:attachment/:id/:style/:created_at",
                                            hash_secret: Hancock::Gallery.config.original_image_hash_secret
          )
        end

      end
    end
  end
end
