module Hancock::Gallery
  if Hancock::Gallery.active_record?
    class Image < ActiveRecord::Base
    end
  end

  class Image
    include Hancock::Gallery::Models::Image

    include Hancock::Gallery::Decorators::Image

    rails_admin(&Hancock::Gallery::Admin::Image.config(nil, false, rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })
  end
end
