module Hancock::Gallery::AutoCrop
  extend ActiveSupport::Concern
  module ClassMethods

    def unset_default_auto_crop_params_for(field = :image, opts = {})
      # undef_method "#{field}_auto_rails_admin_jcrop"
      undef_method "#{field}_autocropped" rescue nil
      undef_method "#{field}_autocropped=" rescue nil
      undef_method "#{field}_default_max_crop_area" rescue nil
      undef_method "#{field}_default_max_crop_area=" rescue nil
      undef_method "#{field}_default_auto_crop_method" rescue nil
      undef_method "#{field}_default_auto_crop_method=" rescue nil
      undef_method "#{field}_style_for_autocrop" rescue nil
      undef_method "#{field}_default_crop_params" rescue nil
      class_eval <<-RUBY
        def #{field}_auto_rails_admin_jcrop
          true
        end
      RUBY
    end

    def set_default_auto_crop_params_for(field = :image, opts = {})
      _width = opts.delete(:width)
      _height = opts.delete(:height)
      crop_area = [_width, _height].compact
      _default_method = opts.delete(:default_method) || :default_crop_params_for_center

      attr_accessor "#{field}_autocropped".to_sym
      cattr_accessor "#{field}_default_max_crop_area".to_sym, "#{field}_default_auto_crop_method".to_sym
      self.send("#{field}_default_max_crop_area=".to_sym, crop_area)
      self.send("#{field}_default_auto_crop_method=".to_sym, _default_method.to_sym)

      class_eval <<-RUBY
        after_save :#{field}_auto_rails_admin_jcrop
        def #{field}_auto_rails_admin_jcrop
          self.#{field}_autocropped = true if self.#{field}_autocropped == "1"
          self.#{field}_autocropped = false if self.#{field}_autocropped == "0"
          return true if self.#{field}.blank? or !self.#{field}_updated_at_changed? or self.#{field}_autocropped
          self.#{field}_autocropped = true
          auto_rails_admin_jcrop(:#{field})
          return true
        end

        def #{field}_style_for_autocrop(_styles = nil)
          _styles = self.#{field}_styles if _styles.nil? and self.respond_to?(:#{field}_styles)
          _styles = self.#{field}.styles if defined?(::Paperclip) and _styles.nil? and self.respond_to?(:#{field}) and self.#{field}.respond_to?(:styles)
          _methods = [:big, :main, :standard]
          _styles = _styles.call(#{field}) if _styles.respond_to?(:call)
          _style = nil
          if defined?(::Paperclip)
            _methods.each do |m|
              _style = _styles[m]
              _style = _style[:geometry] if _style and _style.is_a?(Hash) or _style.is_a?(Paperclip::Style)
              break if !_style.blank? and _style
            end unless _styles.blank?
          end
          _style
        end

        def #{field}_default_crop_params
          if self.#{field} and !self.#{field}_file_name.blank?
            _default_max_crop_area = self.#{field}_default_max_crop_area
            if defined?(::Paperclip) and (_default_max_crop_area or self.respond_to?(:#{field}_styles))
              if _default_max_crop_area.blank?
                if _style = #{field}_style_for_autocrop
                  # sizes = _style.match(/^(?<width>[\d\.]+)?(x(?<height>[\d\.]+))?/)
                  # need_width = sizes[:width].to_f
                  # need_height = sizes[:height].to_f
                  sizes = Paperclip::Geometry.parse _style
                  need_width = sizes.width.to_f
                  need_height = sizes.height.to_f
                end

              else
                if _default_max_crop_area.is_a?(Hash)
                  need_width = _default_max_crop_area[:width].to_f
                  need_height = _default_max_crop_area[:height].to_f
                else
                  need_width = _default_max_crop_area[0].to_f
                  need_height = _default_max_crop_area[1].to_f
                end
              end
              need_width = need_width.to_f
              need_height = need_height.to_f

              begin
                _file = self.#{field}.queued_for_write.blank? ? self.#{field} : self.#{field}.queued_for_write[:original]
                current_geo = Paperclip::Geometry.from_file(_file)
                current_width = current_geo.width.to_f
                current_height = current_geo.height.to_f
              rescue
                current_width ||= need_width.to_f
                current_height ||= need_height.to_f
              end

              if need_width != 0 and need_height != 0
                _aspect_ratio = need_width / need_height
              else
                _aspect_ratio = current_width / current_height
              end

              _width = (need_width > current_width ? current_width : need_width)
              _width = current_width if _width == 0
              _height = _width / _aspect_ratio
              _height = (_height > current_width ? current_width : _height)
              _width = _height * _aspect_ratio
              _width = (_width > current_width ? current_width : _width)

              self.send(self.#{field}_default_auto_crop_method, :#{field}, _width, _height)
            end
          end
        end
      RUBY
    end

  end
end
