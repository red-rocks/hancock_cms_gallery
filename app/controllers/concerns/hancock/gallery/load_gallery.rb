module Hancock::Gallery::LoadGalleryImages
  extend ActiveSupport::Concern


  def hancock_gallery_render_gallery
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

  def hancock_gallery_gallery_class
    Hancock::Gallery::Gallery
  end

  def hancock_gallery_gallery_images_method
    :images
  end

  def hancock_gallery_load_gallery
    hancock_gallery_gallery_class.find(params[:gallery_id])
  end

  def hancock_gallery_gallery_load_images
    @gallery.send(hancock_gallery_gallery_images_method).enabled.sorted.page(params[:page]).per(hancock_gallery_render_gallery_images_per_page)
  end

  def hancock_gallery_gallery_per_page
    4
  end


end
