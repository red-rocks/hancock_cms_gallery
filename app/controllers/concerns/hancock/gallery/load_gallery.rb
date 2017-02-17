module Hancock::Gallery::LoadGallery
  extend ActiveSupport::Concern


  def hancock_gallery_render_gallery
    redirected = hancock_gallery_gallery_redirect_to_if_no_xhr unless request.xhr?

    unless redirected
      @gallery = hancock_gallery_load_gallery
      @gallery_images = hancock_gallery_gallery_load_images

      @next_page = (params[:page] || 1).to_i + 1

      render_opts = {
        layout:   hancock_gallery_gallery_layout,
        action:   hancock_gallery_gallery_action,
        partial:  hancock_gallery_gallery_partial
      }
      render render_opts.compact
    end
  end



  private
  def hancock_gallery_gallery_layout
    request.xhr? ? false : 'application'
  end

  def hancock_gallery_gallery_action
    'hancock_gallery_render_gallery'
  end

  def hancock_gallery_gallery_partial
    nil
  end

  def hancock_gallery_gallery_redirect_to_if_no_xhr
    nil
  end

  def hancock_gallery_gallery_class
    Hancock::Gallery::Gallery
  end

  def hancock_gallery_gallery_scope
    hancock_gallery_gallery_class.enabled
  end

  def hancock_gallery_gallery_images_method
    :images
  end

  def hancock_gallery_load_gallery
    hancock_gallery_gallery_scope.find(params[:gallery_id])
  end

  def hancock_gallery_gallery_images_scope
    @gallery.send(hancock_gallery_gallery_images_method).enabled.sorted
  end

  def hancock_gallery_gallery_load_images
    if @gallery
      if hancock_gallery_render_gallery_images_load_all_the_rest and params[:page].to_i > 1
        hancock_gallery_gallery_images_scope.skip(hancock_gallery_render_gallery_images_per_page).page.all
      else
        hancock_gallery_gallery_images_scope.page(params[:page]).per(hancock_gallery_render_gallery_images_per_page)
      end
    else
      []
    end
  end

  def hancock_gallery_render_gallery_images_per_page
    4
  end

  def hancock_gallery_render_gallery_images_load_all_the_rest
    false
  end

end
