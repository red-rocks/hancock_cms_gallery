# unless defined?(Hancock) && Hancock.respond_to?(:orm) && [:active_record, :mongoid].include?(Hancock.orm)
#   puts "please use hancock_cms_mongoid or hancock_cms_activerecord"
#   puts "also: please use hancock_cms_news_mongoid or hancock_cms_news_activerecord and not hancock_cms_news directly"
#   exit 1
# end

require "hancock/gallery/version"

# require 'hancock_cms'

if Hancock.mongoid?
  begin
    begin
      require 'glebtv-mongoid-paperclip'
    rescue LoadError
      require 'mongoid-paperclip'
    end
  rescue LoadError
    raise 'Add mongoid-paperclip or glebtv-mongoid-paperclip'
  end
elsif Hancock.active_record?
  require 'paperclip'
end
# require "image_optim"
# require "paperclip-optimizer"

require "ack_rails_admin_jcrop"

require "hancock/gallery/rails_admin_ext/hancock_image"

require 'hancock/gallery/configuration'
require 'hancock/gallery/engine'


module Hancock::Gallery
  include Hancock::Plugin

  autoload :Admin,  'hancock/gallery/admin'
  module Admin
    autoload :Gallery,        'hancock/gallery/admin/gallery'
    autoload :Image,          'hancock/gallery/admin/image'
    autoload :EmbeddedImage,  'hancock/gallery/admin/embedded_image'
  end

  module Models
    autoload :Gallery,        'hancock/gallery/models/gallery'
    autoload :Image,          'hancock/gallery/models/image'
    autoload :EmbeddedImage,  'hancock/gallery/models/embedded_image'

    module Mongoid
      autoload :Gallery,        'hancock/gallery/models/mongoid/gallery'
      autoload :Image,          'hancock/gallery/models/mongoid/image'
      autoload :EmbeddedImage,  'hancock/gallery/models/mongoid/embedded_image'
    end

    module ActiveRecord
      autoload :Gallery,        'hancock/gallery/models/active_record/gallery'
      autoload :Image,          'hancock/gallery/models/active_record/image'
    end
  end

end
