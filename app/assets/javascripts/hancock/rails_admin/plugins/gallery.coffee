#= require_self
#= require "hancock/rails_admin/plugins/gallery/custom/ui"


window.hancock.plugins.gallery ||= {}



$(document).on "click", ".hancock_image_type .remote_url_input", (e)->
  e.preventDefault()
  sibl = $(this).siblings()
  $(this).remove()
  sibl.removeClass('hidden').find(':input').focus()
  return false



$(document).on "click", ".hancock_image_type .delete_button_link", (e)->
  e.preventDefault()
  $(this).siblings('[type=checkbox]').click()
  $(this).siblings('.toggle').toggle('slow')
  $(this).toggleClass('btn-danger btn-info')
  return false



$(document).on "click", ".hancock_image_type .urls_list_block a", (e)->
  e.preventDefault()
  $(this).siblings('.url_block').toggleClass('hidden')
  return false



$(document).on "change", ".hancock_image_type .remote_url_method :input", (e)->
  input = $(e.currentTarget)
  url = input.val()
  if url.length > 0
    input.addClass("valuable").closest(".hancock_image_type").find(":input[type=file]").val("").trigger("change")
    image_container = input.closest(".hancock_image_type").find(".preview")
    url_parts = url.split(".")
    ext = url_parts[url_parts.length-1].split("?")[0]
    if $.inArray(ext, ['gif','png','jpg','jpeg','bmp']) != -1
      image_container.attr("src", url)
      image_container.show()
    else
      image_container.hide()
  else
    input.removeClass("valuable")
    unless input.closest(".hancock_image_type").find(":input[type=file]").val()
      input.closest(".hancock_image_type").find(".preview").hide()



$(document).on "change", ".hancock_image_type [data-fileupload]", (e)->
  input = e.currentTarget
  if input.files and input.files[0]
    $(input).addClass("valuable").closest(".hancock_image_type").find(".remote_url_method :input").val("").trigger("change")
  else
    $(input).removeClass("valuable")
