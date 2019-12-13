module Hancock::Gallery
  module Admin
    module EmbeddedImage
      def self.config(nav_label = I18n.t('hancock.gallery'), fields = {})
        if nav_label.is_a?(Hash)
          nav_label, fields = nav_label[:nav_label], nav_label
        elsif nav_label.is_a?(Array)
          nav_label, fields = nil, nav_label
        end
        nav_label ||= I18n.t('hancock.gallery')

        if fields
          if fields.is_a?(Hash)
            if defined?(HancockShrine)
              fields.reverse_merge!({image: :hancock_shrine})
            else
              fields.reverse_merge!({image: :hancock_image})
            end
          else
            finded = false
            fields.each { |g|
              finded = !!g[:fields][:image] unless finded
            }
            unless finded
              fields << {
                name: :default,
                fields: {
                  image: (defined?(HancockShrine) ? :hancock_shrine : :hancock_image)
                }
              }
            end
          end
        end

        if block_given?
          Hancock::Admin::EmbeddedElement.config(nav_label, fields) do |config|
            yield config
          end
        else
          Hancock::Admin::EmbeddedElement.config(nav_label, fields)
        end
      end
    end
  end
end
