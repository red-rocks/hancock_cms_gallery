module Hancock::Gallery
  if Hancock::Gallery.mongoid?
    class EmbeddedImage < Hancock::EmbeddedElement
      include Hancock::Gallery::Models::EmbeddedImage

      include Hancock::Gallery::Decorators::EmbeddedImage

      rails_admin(&Hancock::Gallery::Admin::EmbeddedImage.config(rails_admin_add_fields) { |config|
        rails_admin_add_config(config)
      })

      # use it in rails_admin in parent model for sort
      # sort_embedded({fields: [:embedded_field_1, :embedded_field_2...]})
      # or u need to override rails_admin in inherited model to add sort field
    end
  end
end
