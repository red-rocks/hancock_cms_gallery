require 'rails/generators'

module Hancock::Gallery::Models
  class GalleryGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)
    argument :class_name_arg, type: :string, default: ""
    argument :image_class_name_arg, type: :string, default: ""

    desc 'Hancock::Gallery Gallery Model generator'
    def gallery
      template 'gallery.erb', "app/models/#{file_name}.rb"
    end

    private
    def class_name
      class_name_arg.blank? ? "SetClassForGallery" : class_name_arg
    end

    def capitalized_class_name
      class_name.capitalize
    end

    def camelcased_class_name
      class_name.camelcase
    end

    def file_name
      underscored_class_name
    end

    def underscored_class_name
      camelcased_class_name.underscore
    end

    def underscored_pluralized_class_name
      underscored_class_name.pluralize
    end

    def camelcased_class_name
      gallery_class_name.camelcase
    end

    def underscored_image_class_name
      image_class_name.underscore
    end

    def camelcased_image_class_name
      image_class_name.camelcase
    end

    def image_class_name
      image_class_name_arg.blank? ? "#{camelcased_class_name}Image" : image_class_name_arg
    end
  end
end
