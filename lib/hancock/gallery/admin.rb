module Hancock::Gallery
  module Admin

    def self.images_block(is_active = false, fields = [:images])
      if is_active.is_a?(Array) or is_active.is_a?(String) or is_active.is_a?(Symbol)
        is_active, fields = false, [is_active].flatten
      elsif is_active.is_a?(Hash)
        is_active, fields = (is_active[:active] || false), (is_active[:fields] || [:images])
      end

      Proc.new {
        active is_active
        label I18n.t('hancock.images')
        field :image, :hancock_image
        fields.map { |f|
          field f
        }

        if block_given?
          yield self
        end
      }
    end

  end
end
