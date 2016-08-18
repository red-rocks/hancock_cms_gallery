window.hancock_cms.gallery.gallery_loader = (target = "[data-hancock-gallery-gallery-loader]")->
  $(document).delegate target, "click", (e)->
    e.preventDefault()

    link = $(e.currentTarget)
    url = link.attr('href')
    url = link.data("url") if !url or url == ""
    if url and url != ""
      $.get url, (data)->
        _target_selector = link.data("target-selector")
        if _target_selector and _target_selector != ""
          _target = $(_target_selector)
          if _target.length > 0
            if link.data("target-replace") == "true"
              _target.replaceWith(data)
            else
              _target.html(data)
            if link.data("loader-remove") == "true"
              link.remove()

        else
          if link.data("loader-insert-data") == "true"
            link.html(data)
          else
            link.replaceWith(data)

        window.hancock_cms.gallery.construct_pages_selector()

    return false
