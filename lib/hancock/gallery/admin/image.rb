module Hancock::Gallery
  module Admin
    module Image
      def self.config(nav_label = nil, without_gallery = false, fields = {})
        if nav_label.is_a?(Hash)
          fields, nav_label = nav_label, nil
        end
        if nav_label.is_a?(Boolean)
          if without_gallery.is_a?(Hash)
            fields, without_gallery = without_gallery, false
          end
          without_gallery, nav_label = nav_label, nil
        end

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
