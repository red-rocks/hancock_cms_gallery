module Hancock::Gallery
  module Models
    module ActiveRecord
      module Image
        extend ActiveSupport::Concern

        included do
          # belongs_to :hancock_gallery_imagable, polymorphic: true

          has_paper_trail
          validates_lengths_from_database
          if Hancock::Gallery.config.localize
            translates :name
          end

          scope :sorted, -> { order(lft: :asc) }
        end
      end
    end
  end
end
