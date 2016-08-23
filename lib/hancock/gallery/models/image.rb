module Hancock::Gallery
  module Models
    module Image
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include Hancock::Gallery::Paperclipable

      include Hancock::Gallery.orm_specific('Image')

      included do
        belongs_to :gallery, class_name: "Hancock::Gallery::Gallery"

        acts_as_nested_set

        hancock_cms_attached_file(:image)

        after_save :image_auto_rails_admin_jcrop
        def image_auto_rails_admin_jcrop
          auto_rails_admin_jcrop(:image)
        end
      end

      def self.manager_default_actions
        super + [:nested_set, :multiple_file_upload_collection]
      end

    end
  end
end
