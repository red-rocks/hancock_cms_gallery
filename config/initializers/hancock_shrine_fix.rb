if defined?(HancockShrine)

  module RailsAdmin
    module Config
      module Fields
        module Types
          class HancockShrine
  
            register_instance_option :image? do
              # if value
              #   value.image?
              # else bindings
              #   !!(bindings and (bindings[:object] || bindings[:abstract_model]&.model)&.try("#{name}_is_image?"))
              # end
              !!(bindings and (bindings[:object] || bindings[:abstract_model]&.model)&.try("#{name}_is_image?"))
            end
  
          end
        end
      end
    end
  end
  
end