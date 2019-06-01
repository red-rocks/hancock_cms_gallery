module Hancock::Gallery
  module Admin
    module Gallery
      def self.config(nav_label = nil, fields = {})
        if nav_label.is_a?(Hash)
          nav_label, fields = nav_label[:nav_label], nav_label
        elsif nav_label.is_a?(Array)
          nav_label, fields = nil, nav_label
        end

        Proc.new {
          navigation_icon 'mdi mdi-image-filter'
          navigation_label(!nav_label.blank? ? nav_label : I18n.t('hancock.gallery'))

          field :enabled, :toggle do
            searchable false
          end

          field :name, :string do
            searchable true
          end
          group :URL, &Hancock::Admin.url_block
          # group :URL do
          #   active false
          #   field :slugs, :hancock_slugs
          #   field :text_slug
          # end

          field :image, :hancock_image

          field :gallerable do
            read_only true
          end

          if Hancock::Gallery.config.cache_support
            group :caching, &Hancock::Cache::Admin.caching_block
          end

          nested_set({max_depth: 1, scopes: []})

          if defined?(RailsAdminMultipleFileUpload)
            multiple_file_upload(
                {
                    fields: [:gallery_images]
                }
            )
          end

          Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

          if block_given?
            yield self
          end
        }
      end
    end
  end
end
