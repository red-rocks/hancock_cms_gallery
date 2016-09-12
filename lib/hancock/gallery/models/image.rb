module Hancock::Gallery
  module Models
    module Image
      extend ActiveSupport::Concern
      include Hancock::Model
      include Hancock::Enableable
      include Hancock::Gallery::Paperclipable

      include Hancock::Gallery.orm_specific('Image')

      included do

        if Hancock.rails4?
          belongs_to :gallery, class_name: "Hancock::Gallery::Gallery"
        else
          belongs_to :gallery, class_name: "Hancock::Gallery::Gallery", optional: true
        end

        acts_as_nested_set

        hancock_cms_attached_file(:image)

        after_save :image_auto_rails_admin_jcrop
        def image_auto_rails_admin_jcrop
          auto_rails_admin_jcrop(:image)
        end

        def self.manager_can_add_actions
          ret = [:nested_set, :multiple_file_upload_collection]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:nested_set, :multiple_file_upload_collection]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end

      end

    end
  end
end
