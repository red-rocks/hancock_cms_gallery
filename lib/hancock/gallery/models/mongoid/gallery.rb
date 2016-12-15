module Hancock::Gallery
  module Models
    module Mongoid
      module Gallery
        extend ActiveSupport::Concern

        included do
          index({gallerable_id: 1, gallerable_type: 1}, {background: true})
          index({enabled: 1, lft: 1}, {background: true})

          field :name, type: String, localize: Hancock::Gallery.configuration.localize

          scope :sorted, -> { order_by([:lft, :asc]) }
        end

      end
    end
  end
end
