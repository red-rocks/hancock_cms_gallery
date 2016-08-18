module Hancock::Gallery
  module Models
    module Gallery
      extend ActiveSupport::Concern
      include Hancock::Model
      include ManualSlug
      include Hancock::Enableable
      include Hancock::Gallery::Paperclipable

      include Hancock::Gallery.orm_specific('Gallery')

      included do
        manual_slug :name

        has_many :gallery_images, class_name: "Hancock::Gallery::Image"
        alias :images :gallery_images

        acts_as_nested_set

        hancock_cms_attached_file(:image)

        # has_many :connected_objects, as: :hancock_gallerable

        after_save do
          auto_rails_admin_jcrop(:image)
        end
      end

      def self.manager_default_actions
        super + [:multiple_file_upload]
      end

    end
  end
end
