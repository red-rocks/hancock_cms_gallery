module Hancock::Gallery
  module Admin
    module Image
      def self.config(nav_label = nil, without_gallery = false, fields = {})
        Proc.new {
          navigation_label(nav_label || I18n.t('hancock.gallery'))
          field :enabled, :toggle do
            searchable false
          end
          unless without_gallery
            field :gallery do
              searchable :name
            end
          end
          field :name, :string do
            searchable true
          end
          field :image, :hancock_image

          nested_set({max_depth: 1, scopes: []})

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
