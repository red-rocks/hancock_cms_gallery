module Hancock::Gallery
  module Models
    module Image
      extend ActiveSupport::Concern
      include Hancock::Model
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

      include Hancock::Gallery.orm_specific('Image')

      included do
        include Hancock::Gallery::Uploadable


        belongs_to :hancock_gallery_imagable, polymorphic: true, optional: true

        belongs_to :gallery, class_name: "Hancock::Gallery::Gallery", optional: true

        acts_as_nested_set

        # set_default_auto_crop_params_for(:image)
        hancock_cms_attached_file(:image)
        # if Hancock::Gallery.config.watermark_support
        #   paperclip_with_watermark(:image)
        # else
        #   hancock_cms_attached_file(:image)
        # end

        def self.rails_admin_name_synonyms
          "Photo Картинки Картинка Изображение Изображения".freeze
        end

        def self.manager_can_add_actions
          ret = [:nested_set]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          # ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret << :hancock_touch if Hancock::Gallery.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:nested_set, :multiple_file_upload_collection]
          # ret += [:multiple_file_upload, :sort_embedded] if Hancock::Gallery.mongoid?
          ret << :model_settings if Hancock::Gallery.config.model_settings_support
          ret << :model_accesses if Hancock::Gallery.config.user_abilities_support
          ret << :hancock_touch if Hancock::Gallery.config.cache_support
          ret += [:comments, :model_comments] if Hancock::Gallery.config.ra_comments_support
          ret.freeze
        end

      end

      class_methods do
        def inherited(subclass)
          puts 'image inherited'
          subclass.hancock_cms_attached_file(:image)
        end
      end

    end
  end
end
