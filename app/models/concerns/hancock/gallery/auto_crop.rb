module Hancock::Gallery::AutoCrop
  extend ActiveSupport::Concern
  module ClassMethods

    def set_default_auto_crop_params_for(field = :image, opts = {})
      _width = opts.delete(:width)
      _height = opts.delete(:height)
      crop_area = [_width, _height].compact
      _default_method = opts.delete(:default_method) || :default_crop_params_for_center

      cattr_accessor "#{field}_default_max_crop_area".to_sym, "#{field}_default_auto_crop_method".to_sym
      self.send("#{field}_default_max_crop_area=".to_sym, crop_area)
      self.send("#{field}_default_auto_crop_method=".to_sym, _default_method.to_sym)

      class_eval <<-EVAL
        after_save :#{field}_auto_rails_admin_jcrop
        def #{field}_auto_rails_admin_jcrop
          auto_rails_admin_jcrop(#{field.to_sym})
        end

        def #{field}_default_crop_params
          if #{field} and !#{field}_file_name.blank?
            _default_max_crop_area = self.#{field}_default_max_crop_area
            if _default_max_crop_area or self.respond_to?(:#{field}_styles) and (_#{field}_styles = self.#{field}_styles)
              unless _default_max_crop_area
                _methods = [:big, :main, :standard]
                _#{field}_styles = _#{field}_styles.call(#{field}) if _#{field}_styles.respond_to?(:call)
                _style = nil
                _methods.each do |m|
                  _style = _#{field}_styles[m]
                  _style = _style[:geometry] if _style and _style.is_a?(Hash)
                  break if !_style.blank? and _style
                end
                if _style
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

              current_geo = Paperclip::Geometry.from_file(#{field})
              current_width = current_geo.width.to_f
              current_height = current_geo.height.to_f

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

              self.send(self.#{field}_default_auto_crop_method, #{field.to_sym}, _width, _height)
            end
          end
        end
      EVAL
    end

  end
end
