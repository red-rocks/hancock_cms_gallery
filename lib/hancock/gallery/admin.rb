module Hancock::Gallery
  module Admin

    # images_block(is_active = false, fields = [:images], options = {})
    # images_block(is_active = false, options = {field: [:images]})
    # images_block(fields = [:images], options = {active: false})
    # images_block(options = {fields: [:images], active: false})
    # images_block(is_active = false, fields = [:images], options = {})

    def self.images_block(is_active = false, fields = [:images], options = {})
      if is_active.is_a?(Array) or is_active.is_a?(String) or is_active.is_a?(Symbol)
        is_active, fields = false, [is_active].flatten
      elsif is_active.is_a?(Hash)
        is_active, fields = (is_active[:active] || false), (is_active[:fields] || [:images])
      elsif fields.is?(Hash)
        is_active, fields, options = (fields[:active] || false), (is_active[:fields] || [:images]), fields
      end
      if fields.is_a?(Array)
        fields.map! { |f|
          if f.is_a?(Hash)
            f
          elsif f.is_a?(Array)
            _ret = {"#{f.first}" => f[1..-1]}
          else
            { "#{f}": nil }
          end
        }
        fields = fields.reduce({}, :merge)

      end


      Proc.new {
        active is_active
        label options[:label] || I18n.t('hancock.images')
        if defined?(HancockShrine)
          field :image, :hancock_shrine
        else
          field :image, :hancock_image
        end

        Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)

        if block_given?
          yield self
        end
      }
    end

  end
end
