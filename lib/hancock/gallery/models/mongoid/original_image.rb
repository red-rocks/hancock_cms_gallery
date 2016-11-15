module Hancock::Gallery
  module Models
    module Mongoid
      module OriginalImage
        extend ActiveSupport::Concern

        included do
          field :original, type: BSON::Binary
        end

      end
    end
  end
end
