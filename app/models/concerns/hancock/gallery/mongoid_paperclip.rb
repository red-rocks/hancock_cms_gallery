if Hancock.mongoid?
  module Hancock::Gallery::MongoidPaperclip
    extend ActiveSupport::Concern

    include Mongoid::Paperclip

    module ClassMethods
      def hancock_cms_mongoid_attached_file(name, opts = {})
        name = name.to_sym
        is_image = true
        styles_method_name = nil
        unless opts.blank?
          content_type = opts.delete(:content_type)
          jcrop_options = opts.delete(:jcrop_options)
          is_image = opts.delete(:is_image)
          is_image = true if is_image.nil?
        end

        if is_image
          if defined?(::PaperclipOptimizer)
            opts[:processors] ||= []
            opts[:processors] << :paperclip_optimizer
            opts[:processors].flatten!
            opts[:processors].uniq!
          end

          opts[:convert_options] = {all: "-quality 75 -strip"} if opts[:convert_options].blank?

          if opts[:styles].blank?
            styles_method_name = "#{name}_styles"
            opts[:styles] = lambda { |attachment| attachment.instance.send(styles_method_name) }
          end

          if name == :image
            class_eval <<-EVAL
              def image_default_crop_params
                if image and !image_file_name.blank?
                  _methods = [:main, :standard, :big]
                  if self.respond_to?(:image_styles) and (_image_styles = self.image_styles)
                    _image_styles = _image_styles.call(image) if _image_styles.respond_to?(:call)
                    _style = nil
                    _methods.each do |m|
                      _style = _image_styles[m]
                      _style = _style[:geometry] if _style and _style.is_a?(Hash)
                      break if !_style.blank? and _style
                    end
                    if _style
                      # sizes = _style.match(/^(?<width>\d+)?(x(?<height>\d+))?/)
                      # need_width = sizes[:width].to_i
                      # need_height = sizes[:height].to_i
                      sizes = Paperclip::Geometry.parse _style
                      need_width = sizes.width.to_i
                      need_height = sizes.height.to_i

                      current_geo = Paperclip::Geometry.from_file(image)
                      current_width = current_geo.width.to_i
                      current_height = current_geo.height.to_i

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

                      default_crop_params_for_center(:image, _width, _height)
                    end
                  end
                end
              end
            EVAL
          end

        end

        has_mongoid_attached_file name, opts
        # validates_attachment name, content_type: content_type unless content_type.blank?
        validates_attachment_content_type name, content_type: /\Aimage\/.*\Z/ if is_image

        class_eval <<-EVAL
          def #{name}_file_name=(val)
            return self[:#{name}_file_name] = ""  if val == ""
            return self[:#{name}_file_name] = nil if val == nil
            val = val.to_s
            extension = File.extname(val)[1..-1]
            file_name = val[0..val.size-extension.size-1]
            self[:#{name}_file_name] = "\#{file_name.filename_to_slug}.\#{extension.filename_to_slug}"
          end

          def #{name}_svg?
            #{name}_content_type =~ /svg/
          end

          def #{name}_url(opts)
            if #{name}_svg?
              #{name}.url
            else
              #{name}.url(opts)
            end
          end
        EVAL
        if defined?(::PaperclipOptimizer)
          class_eval <<-EVAL
            before_#{name}_post_process do
              p_o = self.#{name}.processors.delete :paperclip_optimizer
              self.#{name}.processors << p_o if p_o
              true
            end
          EVAL
        end
        jcrop_options ||= {}
        if jcrop_options
          class_eval <<-EVAL
            def #{name}_jcrop_options
              #{jcrop_options}
            end
          EVAL
        end
        if styles_method_name
          class_eval <<-EVAL
            def #{styles_method_name}
              {
                thumb: '128x128'
              }
            end
          EVAL
        end

      end
    end
  end
end
