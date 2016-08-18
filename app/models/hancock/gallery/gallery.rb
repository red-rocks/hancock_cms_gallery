module Hancock::Gallery
  if Hancock::Gallery.active_record?
    class Gallery < ActiveRecord::Base
    end
  end

  class Gallery
    include Hancock::Gallery::Models::Gallery

    include Hancock::Gallery::Decorators::Gallery

    rails_admin(&Hancock::Gallery::Admin::Gallery.config(nil, rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })
  end
end
