#= require_self
#= require "hancock/rails_admin/plugins/gallery/custom/ui"


window.hancock.plugins.gallery ||= {}


# TODO hancock_shrine_type
$(document).on "click", ".hancock_image_type .remote_url_input, .hancock_shrine_type .remote_url_input", (e)->
  e.preventDefault()
  sibl = $(this).siblings()
  $(this).remove()
  sibl.removeClass('hidden').find(':input').focus()
  return false



$(document).on "click", ".hancock_image_type .delete_button_link, .hancock_shrine_type .delete_button_link", (e)->
  e.preventDefault()
  $(this).siblings('[type=checkbox]').click()
  # $(this).siblings('.delete-checkbox[type=checkbox]').click()
  $(this).siblings('.toggle').toggle('slow').toggleClass("mark-deleted")
  $(this).toggleClass('btn-danger btn-info')
  return false



$(document).on "click", ".hancock_image_type .urls_list_block a, .hancock_shrine_type .urls_list_block a", (e)->
  e.preventDefault()
  $(this).siblings('.url_block').toggleClass('hidden')
  return false



$(document).on "change", ".hancock_image_type .remote_url_method :input, .hancock_shrine_type .remote_url_method :input", (e)->
  input = $(e.currentTarget)
  url = input.val()
  if url.length > 0
    input.addClass("valuable").closest(".hancock_image_type, .hancock_shrine_type").find(":input[type=file]").val("").trigger("change")
    image_container = input.closest(".hancock_image_type, .hancock_shrine_type").find(".preview")
    url_parts = url.split(".")
    ext = url_parts[url_parts.length-1].split("?")[0]
    if $.inArray(ext, ['gif','png','jpg','jpeg','bmp']) != -1
      image_container.attr("src", url)
      image_container.show()
    else
      image_container.hide()
  else
    input.removeClass("valuable")
    unless input.closest(".hancock_image_type, .hancock_shrine_type").find(":input[type=file]").val()
      input.closest(".hancock_image_type, .hancock_shrine_type").find(".preview").hide()



$(document).on "change", ".hancock_image_type [data-fileupload], .hancock_shrine_type [data-fileupload]", (e)->
  input = e.currentTarget
  if input.files and input.files[0]
    $(input).addClass("valuable").closest(".hancock_image_type, .hancock_shrine_type").find(".remote_url_method :input").val("").trigger("change")
  else
    $(input).removeClass("valuable")



$(document).on "click", ".hancock_shrine_type .crop-btn", (e)->
  e.preventDefault()
  fieldWrapper = $(e.currentTarget).closest('.hancock_shrine_type')
  remoteForm = $.ra.remoteForm()
  dialog = remoteForm._getModal()
  dialogTitle = dialog.find('.modal-header-title')
  dialogBody = dialog.find('.modal-body')
  saveButton = dialog.find(".save-action")
  cancelButton = dialog.find(".cancel-action")


  dialogTitle.text("Обрезка")
  saveButton.text("Обрезать")
  cancelButton.text("Отменить")


  field = fieldWrapper.find('[type=file]')
  fieldCache = fieldWrapper.find('.cache[type=hidden]')
  if fieldCache.val()
    cached = JSON.parse(fieldCache.val())
    is_stored = cached.storage == "store"
    storage_path = (if (!cached.storage or is_stored) then "" else ("/" + cached.storage))
    prefix = cached.prefix || 'uploads'
    actualImageUrl = "/#{prefix}#{storage_path}/#{cached.id}"
  else
    actualImageUrl = field.data('original')

  csrf_param = document.querySelector('meta[name=csrf-param]').content
  csrf_token = document.querySelector('meta[name=csrf-token]').content

  cropper_image = "<img id='cropper-image' style='width: 100%;' src='#{actualImageUrl}'>"
  cropper_image_wrapper = "<div style='max-width: 100%;'>#{cropper_image}</div>"
  form_action = field.closest("form").attr("action").replace(/\/edit$/i, "/hancock_shrine_crop")
  cropper_form = [
    "<form action='#{form_action}' data-remote='true' id='cropper-form' accept-charset='UTF-8' method='post'>",
    "<input type='hidden' name='#{csrf_param}' value='#{csrf_token}'>",

    "<input type='hidden' name='name' value='image'>",
    "<input type='hidden' name='image' value='#{JSON.stringify(cached) || ""}'>"

    "<input type='hidden' name='crop_x' value=''>",
    "<input type='hidden' name='crop_y' value=''>",
    "<input type='hidden' name='crop_w' value=''>",
    "<input type='hidden' name='crop_h' value=''>",
    "</form>"
  ].join("")
  dialogBody.html(cropper_image_wrapper + cropper_form)

  
  $image = dialogBody.find('#cropper-image')
  $image.load ->
    $image.cropper({
      aspectRatio: JSON.parse(field.data('rails-admin-crop-options').aspectRatio),
      viewMode: 1,
      scalable: false,
      zoomable: false,
      # minContainerWidth: 750
      # minContainerHeight: 500
      crop: (event)->
        # console.log(event.detail.x)
        # console.log(event.detail.y)
        # console.log(event.detail.width)
        # console.log(event.detail.height)
        # console.log(event.detail.rotate)
        # console.log(event.detail.scaleX)
        # console.log(event.detail.scaleY)
    })

  $cropper_form = $('#cropper-form')


  saveButton.on 'click', (e)->
    e.preventDefault()
    cropper = $image.data('cropper')

    # TODO: WTF !!!!
    $cropper_form = $('#cropper-form') if $cropper_form.length == 0
    $cropper_form.on "ajax:error ajax:complete", (e, xhr, status, error)->
      if error
        alert(error)
        console.log(error)
        console.log(xhr)
      else
        data = xhr.responseJSON
        fieldCache.val('')
        field.data('original', data.original.url)
        
        console.log(data)
        thumb = (data.thumb || data.thumbnail || data.main || data.original)
        console.log(thumb)
        preview = fieldCache.siblings('.toggle').find('.preview img')
        preview.attr('src', thumb.url)
      dialog.modal('hide')

    
    scaleX = cropper.imageData.naturalWidth / cropper.imageData.width
    scaleY = cropper.imageData.naturalHeight / cropper.imageData.height
    cropBoxData = cropper.cropBoxData
    console.log(cropper)
    console.log(cropBoxData)
    console.log(cropBoxData.top)
    console.log(cropBoxData.left)
    console.log(cropBoxData.width)
    console.log(cropBoxData.height)
    $cropper_form.find('[name="crop_x"]').val(cropBoxData.left * scaleX)
    $cropper_form.find('[name="crop_y"]').val(cropBoxData.top * scaleY)
    $cropper_form.find('[name="crop_w"]').val(cropBoxData.width * scaleX)
    $cropper_form.find('[name="crop_h"]').val(cropBoxData.height * scaleY)
    $cropper_form.submit()
    # dialog.modal('hide')

  cancelButton.on 'click', (e)->
    e.preventDefault()
    dialog.modal('hide')
  
  return false
