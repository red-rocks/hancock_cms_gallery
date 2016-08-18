module Hancock::Gallery
  module Admin
    module EmbeddedImage
      def self.config(fields = {})

        if fields
          if fields.is_a?(Hash)
            fields.reverse_merge!({image: :hancock_image})
          else
            finded = false
            fields.each { |g|
              finded = !!g[:fields][:image] unless finded
            }
            unless finded
              fields << {
                name: :image,
                fields: {
                  image: :hancock_image
                }
              }
            end
          end
        end

        if block_given?
          Hancock::Admin::EmbeddedElement.config(nil, fields) do |config|
            yield config
          end
        else
          Hancock::Admin::EmbeddedElement.config(nil, fields)
        end
      end
    end
  end
end
