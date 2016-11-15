module Hancock::Gallery
  if Hancock::Gallery.mongoid?

    class OriginalImage
      include Hancock::Gallery::Models::OriginalImage

      include Hancock::Gallery::Decorators::OriginalImage

      rails_admin(&Hancock::Gallery::Admin::OriginalImage.config(rails_admin_add_fields) { |config|
        rails_admin_add_config(config)
      })
    end
    
  end
end
