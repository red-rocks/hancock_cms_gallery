module Hancock::Gallery
  module Admin
    module Image
      def self.config(nav_label = nil, without_gallery = false, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, without_gallery, fields = nav_label[:nav_label], (nav_label[:without_gallery] || false), nav_label
        elsif nav_label.is_a?(Array)
          nav_label, without_gallery, fields = nil, false, nav_label
        end
        if nav_label.is_a?(Boolean)
          if without_gallery.is_a?(Hash)
            nav_label, without_gallery, fields = without_gallery[:nav_label], nav_label, without_gallery
          end
          nav_label, without_gallery, fields = fields[:nav_label], nav_label, fields
        end

        Proc.new {
          navigation_label(!nav_label.blank? ? nav_label : I18n.t('hancock.gallery'))
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

          group :caching, &Hancock::Admin.caching_block

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
