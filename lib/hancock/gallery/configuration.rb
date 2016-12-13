module Hancock::Gallery
  include Hancock::PluginConfiguration

  def self.config_class
    Configuration
  end

  class Configuration

    attr_accessor :localize
    
    attr_accessor :cache_support

    attr_accessor :model_settings_support
    attr_accessor :user_abilities_support
    attr_accessor :ra_comments_support
    attr_accessor :watermark_support

    def initialize
      @localize = Hancock.config.localize

      @cache_support  = defined?(Hancock::Cache)

      @model_settings_support = defined?(RailsAdminModelSettings)
      @user_abilities_support = defined?(RailsAdminUserAbilities)
      @ra_comments_support = defined?(RailsAdminComments)
      @watermark_support = defined?(PaperclipWatermark)
    end
  end
end
