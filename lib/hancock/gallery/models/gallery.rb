module Hancock::Gallery
  module Models
    module Gallery
      extend ActiveSupport::Concern
      include Hancock::Model
      include ManualSlug
      include Hancock::Enableable

      # if defined?(Paperclip)
      #   include Hancock::Gallery::Paperclipable
      # elsif defined?(Shrine)
      #   include Hancock::Gallery::Shrineable
      # end
      
      # if Hancock::Gallery.config.watermark_support
      #   include Hancock::Gallery::Watermarkable
      # end

      if Hancock::Gallery.config.cache_support
        include Hancock::Cache::Cacheable
      end
      if Hancock::Seo.config.model_settings_support
        include Hancock::Settingable
      end

      include Hancock::Gallery.orm_specific('Gallery')

      included do
        include Hancock::Gallery::Uploadable
        
        manual_slug :name

        has_many :gallery_images, class_name: "Hancock::Gallery::Image"
        alias :images :gallery_images

        acts_as_nested_set

        # set_default_auto_crop_params_for(:image)
        hancock_cms_attached_file(:image)
        # if Hancock::Gallery.config.watermark_support
        #   paperclip_with_watermark(:image)
        # else
        #   hancock_cms_attached_file(:image)
        # end

        belongs_to :gallerable, polymorphic: true, optional: true

        def self.rails_admin_name_synonyms
          "".freeze
        end

        def self.manager_can_add_actions
          ret = [:nested_set, :multiple_file_upload]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          # ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret << :hancock_touch if Hancock::Gallery.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:nested_set, :multiple_file_upload]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret << :hancock_touch if Hancock::Gallery.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end

      end

    end
  end
end
