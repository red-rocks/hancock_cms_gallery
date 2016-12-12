module Hancock::Gallery
  module Models
    module Mongoid
      module Image
        extend ActiveSupport::Concern

        included do
          index({gallery_id: 1})
          index({enabled: 1, lft: 1})

          field :name, type: String, localize: Hancock::Gallery.configuration.localize

          scope :sorted, -> { order_by([:lft, :asc]) }
        end
      end
    end
  end
end
