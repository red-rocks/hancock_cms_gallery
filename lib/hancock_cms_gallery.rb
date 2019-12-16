require "hancock/gallery/version"

begin
  begin
    require 'hancock_shrine'
  rescue LoadError
    require 'shrine-mongoid'
  end
rescue LoadError
end

if Hancock.mongoid?
  begin
    begin
      require 'glebtv-mongoid-paperclip'
    rescue LoadError
      require 'mongoid-paperclip'
    end
  rescue LoadError
    raise 'Add glebtv-mongoid-paperclip (*recommended*) or mongoid-paperclip or  in Gemfile' unless defined?(::Shrine)
  end
elsif Hancock.active_record?
  begin
    require 'paperclip'
  rescue LoadError
    raise 'Add paperclip in Gemfile' unless defined?(::Shrine)
  end
end


if defined?(::Paperclip)
  require 'hancock/gallery/paperclip_patch'
  # require "image_optim"
  # require "paperclip-optimizer"
end

# require "ack_rails_admin_jcrop"

# require "hancock/gallery/rails_admin_ext/hancock_image"

require 'hancock/gallery/configuration'
require 'hancock/gallery/engine'


module Hancock::Gallery
  include Hancock::Plugin

  autoload :Admin,  'hancock/gallery/admin'
  module Admin
    autoload :Gallery,        'hancock/gallery/admin/gallery'
    autoload :Image,          'hancock/gallery/admin/image'
    # autoload :OriginalImage,  'hancock/gallery/admin/original_image'
    autoload :EmbeddedImage,  'hancock/gallery/admin/embedded_image'
  end

  module Models
    autoload :Gallery,        'hancock/gallery/models/gallery'
    autoload :Image,          'hancock/gallery/models/image'
    # autoload :OriginalImage,  'hancock/gallery/models/original_image'
    autoload :EmbeddedImage,  'hancock/gallery/models/embedded_image'

    module Mongoid
      autoload :Gallery,        'hancock/gallery/models/mongoid/gallery'
      autoload :Image,          'hancock/gallery/models/mongoid/image'
      # autoload :OriginalImage,  'hancock/gallery/models/mongoid/original_image'
      autoload :EmbeddedImage,  'hancock/gallery/models/mongoid/embedded_image'
    end

    module ActiveRecord
      autoload :Gallery,        'hancock/gallery/models/active_record/gallery'
      autoload :Image,          'hancock/gallery/models/active_record/image'
      # autoload :OriginalImage,  'hancock/gallery/models/active_record/original_image'
    end
  end

end
