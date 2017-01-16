module Hancock::Gallery::Decorators
  module Image
    extend ActiveSupport::Concern

    included do

      # def self.default_cache_keys
      #   []
      # end

      # # after_save :image_auto_rails_admin_jcrop
      # def image_auto_rails_admin_jcrop
      #   auto_rails_admin_jcrop(:image) # or nil for cancel autocrop
      # end

      # # hancock_cms_attached_file(:image)
      # def image_styles
      #   super
      # end
      # def image_jcrop_options
      #   super
      # end

      ############# rails_admin ##############
      # def self.rails_admin_name_synonyms
      #   "Photo Картинки Картинка Изображение Изображения".freeze
      # end
      # def self.rails_admin_navigation_icon
      #   'icon-picture'.freeze
      # end
      #
      # def self.rails_admin_add_fields
      #   [] #super
      # end
      #
      # def self.rails_admin_add_config(config)
      #   #super(config)
      # end
      #
      # def self.admin_can_user_defined_actions
      #   [].freeze
      # end
      # def self.admin_cannot_user_defined_actions
      #   [].freeze
      # end
      # def self.manager_can_user_defined_actions
      #   [].freeze
      # end
      # def self.manager_cannot_user_defined_actions
      #   [].freeze
      # end
      # def self.rails_admin_user_defined_visible_actions
      #   [].freeze
      # end

    end

  end
end
