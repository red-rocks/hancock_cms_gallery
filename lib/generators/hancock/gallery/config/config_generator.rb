require 'rails/generators'

module Hancock::Gallery
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Hancock::Gallery Config generator'
    def config
      template 'hancock_gallery.erb', "config/initializers/hancock_gallery.rb"
    end

  end
end
