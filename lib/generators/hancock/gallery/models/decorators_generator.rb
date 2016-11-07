require 'rails/generators'

module Hancock::Gallery::Models
  class DecoratorsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../../../app/models/concerns/hancock/gallery/decorators', __FILE__)
    argument :models, type: :array, default: []

    desc 'Hancock::Gallery Models decorators generator'
    def decorators
      (models == ['all'] ? permitted_models : models & permitted_models).each do |m|
        copy_file "#{m}.rb", "app/models/concerns/hancock/gallery/decorators/#{m}.rb"
      end
    end

    private
    def permitted_models
      ['embedded_image', 'gallery', 'image']
    end

  end
end
