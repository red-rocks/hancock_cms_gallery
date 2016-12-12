module Hancock::Gallery
  module Models
    module Mongoid
      module OriginalImage
        extend ActiveSupport::Concern

        included do
          index({originable_id: 1, originable_type: 1})

          field :original, type: BSON::Binary
        end

      end
    end
  end
end
