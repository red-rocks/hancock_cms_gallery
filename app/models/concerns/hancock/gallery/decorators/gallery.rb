module Hancock::Gallery::Decorators
  module Gallery
    extend ActiveSupport::Concern

    included do
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
