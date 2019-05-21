require 'mini_magick'

module RailsAdmin

  class JcropController < RailsAdmin::ApplicationController
    skip_before_action :get_model rescue nil # prevent undefined method error
    before_action :get_model, :get_object, :get_field, :get_fit_image

    helper_method :abstract_model, :geometry

    def edit
      @form_options = {}
      @form_options[:method] = :put
      @form_options[:'data-title'] = "#{I18n.t("admin.actions.crop.menu").capitalize} #{abstract_model.model.human_attribute_name @field}"

      @image_tag_options = {}
      @image_tag_options[:class] = "jcrop-subject"
      @file_path=''
      
      current_field = @object.send(@field)
      
      #Condition for Carrierwave.
      if is_this_carrierwave?(current_field)
        @file_path = if current_field._storage.to_s =~ /Fog/
          current_field.url
        else
          current_field.path
        end
        @image_tag_options[:'data-geometry'] = geometry(@file_path).join(",")

      #Condition for Paperclip.
      elsif is_this_paperclip?(current_field)
        @file_path = if current_field.options[:storage].to_s =='s3'
          current_field.url
        else
          current_field.path
        end
        @image_tag_options[:'data-geometry'] = geometry(@file_path).join(",")

      #Condition for Shrine.
      elsif is_this_shrine?(current_field)
        current_field = current_field[:original] if current_field.is_a?(Hash)
        @file_path = if defined?(::Shrine::Storage::S3) and (current_field.storage.is_a?(::Shrine::Storage::S3))
          current_field.url
        else
          current_field.to_io
        end

        metadata = current_field.metadata
        @image_tag_options[:'data-geometry'] = [metadata["width"], metadata["height"]].join(",")
      end
      

      if @fit_image_geometry
        fit_image_geometry = fit_image_geometry(@file_path)

        @form_options[:'style'] = "margin-left: #{375 - (fit_image_geometry[0]/2) - 15}px;"

        @image_tag_options[:style] = ""
        @image_tag_options[:style] << "width: #{fit_image_geometry[0]}px !important;"
        @image_tag_options[:style] << "height: #{fit_image_geometry[1]}px !important;"
        @image_tag_options[:style] << "border: 1px solid #AAA !important;"
      end

      respond_to do |format|
        format.html
        format.js   { render :edit, :layout => false }
      end
    end

    def update
      if params[:cancel_crop] == "1"
        image_obj = @object.send(params[:crop_field])
        _path = if image_obj.is_a?(Hash)
          image_obj[:original].to_io.path
        elsif image_obj.is_a?(Paperclip::Attachment)
          image_obj.path
        end
        if _path and File.exists?(_path)
          _geometry = geometry(_path)
        else
          _geometry = [0, 0]
        end
        params[:crop_x] = 0
        params[:crop_y] = 0
        params[:crop_w] = _geometry[0]
        params[:crop_h] = _geometry[1]
      end
      
      _field = @object.send(params[:crop_field])

      @object.rails_admin_crop! params.merge(crop_process_before: '+repage', crop_process_after: '+repage'), upload_plugin_prefix

      respond_to do |format|
        format.html { redirect_to_on_success }
        format.js do
          asset = @object.send @field
          if asset.is_a?(Hash)
            _asset = asset[:original] 
          else
            _asset = asset
          end
          urls = {:original => _asset.url}
          thumbnail_names.each { |name| 
            urls[name] = if asset.is_a?(Hash)
              (asset[name] || asset[name.to_sym]).url
            else
              (asset.is_a?(Paperclip::Attachment) ? asset.url(name) : asset.url)
            end
          }

          render :json => {
            :id    => @object.id,
            :label => @model_config.with(:object => @object).object_label,
            :field => @field,
            :urls  => urls
          }
        end
      end
    end

    private

    def upload_plugin_prefix(field = @field)
      _field = @object.send(field)

      if is_this_carrierwave?(_field)
        'cw_'
      elsif is_this_paperclip?(_field)
        'pc_'
      elsif is_this_shrine?(_field)
        's_'
      else 
        nil
      end
    end

    def thumbnail_names
      RailsAdminJcrop::AssetEngine.send("#{upload_plugin_prefix}thumbnail_names", @object, @field)
    end

    def get_fit_image
      @fit_image = params[:fit_image] == "true" ? true : false
    end

    def get_field
      @field = params[:field]
    end

    def geometry(image_path)
      image = MiniMagick::Image.open(image_path)
      [image[:width], image[:height]]
    end

    def fit_image_geometry(image_path)
      image = MiniMagick::Image.open(image_path)
      # Magic number origin: https://github.com/janx/rails_admin_jcrop/pull/2
      image.resize "720x400"
      [image[:width], image[:height]]
    end

    def cropping?
      [:crop_x, :crop_y, :crop_w, :crop_h].all? {|c| params[c].present?}
    end


    def is_this_carrierwave?(_field)
      !!(defined?(::Carrierwave) and _field.class.to_s =~ /Uploader/)
    end
    def is_this_paperclip?(_field)
      !!(defined?(::Paperclip) and _field.class.to_s =~ /Paperclip/)
    end
    def is_this_shrine?(_field)
      !!(defined?(::Shrine) and (_field.is_a?(Hash) or _field.class.to_s =~ /UploadedFile/))
    end
  end

end
