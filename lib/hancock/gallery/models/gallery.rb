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

        belongs_to :gallerable, polymorphic: true

        after_save :image_auto_rails_admin_jcrop
        def image_auto_rails_admin_jcrop
          auto_rails_admin_jcrop(:image)
        end

        def self.manager_can_add_actions
          ret = [:nested_set]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:nested_set]
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
