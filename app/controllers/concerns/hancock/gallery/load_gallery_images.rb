module Hancock::Gallery::LoadGalleryImages
  extend ActiveSupport::Concern


  def hancock_gallery_render_gallery_images
    redirected = hancock_gallery_gallery_images_redirect_to_if_no_xhr unless request.xhr?

    unless redirected
      @gallery_images = hancock_gallery_load_gallery_images

      @next_page = (params[:page] || 1).to_i + 1

      render_opts = {
        layout:   hancock_gallery_gallery_images_layout,
        action:   hancock_gallery_gallery_images_action,
        partial:  hancock_gallery_gallery_images_partial
      }
      render render_opts.compact
    end
  end



  private
  def hancock_gallery_gallery_images_layout
    request.xhr? ? false : 'application'
  end

  def hancock_gallery_gallery_images_action
    'hancock_gallery_render_gallery_images'
  end

  def hancock_gallery_gallery_images_partial
    nil
  end

  def hancock_gallery_gallery_images_redirect_to_if_no_xhr
    nil
  end

  def hancock_gallery_gallery_image_class
    Hancock::Gallery::Image
  end

  def hancock_gallery_gallery_image_scope
    hancock_gallery_gallery_image_class.enabled.sorted
  end

  def hancock_gallery_load_gallery_images
    if hancock_gallery_gallery_images_load_all_the_rest and params[:page].to_i > 1
      hancock_gallery_gallery_image_scope.skip(hancock_gallery_gallery_images_per_page).page.all
    else
      hancock_gallery_gallery_image_scope.page(params[:page]).per(hancock_gallery_gallery_images_per_page)
    end
  end

  def hancock_gallery_gallery_images_per_page
    4
  end

  def hancock_gallery_gallery_images_load_all_the_rest
    false
  end


end
