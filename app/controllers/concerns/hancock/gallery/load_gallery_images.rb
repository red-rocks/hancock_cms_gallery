module Hancock::Gallery::LoadGalleryImages
  extend ActiveSupport::Concern


  def hancock_gallery_render_gallery_images
    @gallery_images = hancock_gallery_load_gallery_images

    @next_page = (params[:page] || 1).to_i + 1

    render_opts = {
      layout:   hancock_gallery_gallery_images_layout,
      action:   hancock_gallery_gallery_images_action,
      partial:  hancock_gallery_gallery_images_partial
    }
    render render_opts.compact
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

  def hancock_gallery_gallery_image_class
    Hancock::Gallery::Image
  end

  def hancock_gallery_load_gallery_images
    hancock_gallery_gallery_image_class.enabled.sorted.page(params[:page]).per(hancock_gallery_gallery_images_per_page)
  end

  def hancock_gallery_gallery_images_per_page
    4
  end



end
