window.hancock_cms.gallery.construct_pages_selector = (target = "[data-hancock-gallery-page-selector]")->
  pages_selector = $(target)
  pages_array = []
  pages_selector_html = ""
  $(".hancock_gallery_page_title_block").each ->
    pages_array.push(parseInt($(this).data('page')))

  pages_array.sort (a,b)->
    a - b

  $(pages_array).each ->
    pages_selector_html += "<a href='#page-" + this + "' class='page_selector_block' title='" + this + "'>" + this + "</a>"
  pages_selector.html(pages_selector_html)
  window.hancock_cms.gallery.format_pages_selector()



window.hancock_cms.gallery.format_pages_selector = (target = ".hancock_gallery_page_selector")->
  pages_selector = $(target)
  pages_array = []
  $(".hancock_gallery_page_title_block").each ->
    pages_array.push([parseInt($(this).data('page')), $(this), $(this).offset().top])

  first_window  = parseInt(pages_selector.data('first-window')) || 1
  center_window = parseInt(pages_selector.data('window'))       || 2
  last_window   = parseInt(pages_selector.data('last-window'))  || 1
  top_offset    = parseInt(pages_selector.data('top-offset'))   || 0
  scroll_top    = $(window).scrollTop()                         || 0

  min_page = 99999999
  max_page = 0
  current_page = null
  min_diff = 99999999

  $(pages_array).each ->
    if (this[2] - (scroll_top + top_offset) > 0) and min_diff > this[2] - (scroll_top + top_offset)
      current_page = this[0]
      min_diff = this[2] - (scroll_top + top_offset)
    if min_page > this[0]
      min_page = this[0]
    if max_page < this[0]
      max_page = this[0]

  if current_page
    $(pages_array).each ->
      f_w = this[0] >= min_page                     and this[0] <= min_page + first_window
      c_w = this[0] >= current_page - center_window and this[0] <= current_page + center_window
      l_w = this[0] >= max_page - last_window       and this[0] <= max_page

      page_selector_block = $(".page_selector_block[href='#page-" + this[0] + "']")

      if f_w or c_w or l_w
        page_selector_block.addClass("showed").removeClass("hidden")
      else
        page_selector_block.addClass("hidden").removeClass("showed")

      if this[0] == current_page
        page_selector_block.addClass("current")
      else
        page_selector_block.removeClass("current")



$(window).scroll ->
  window.hancock_cms.gallery.format_pages_selector()
