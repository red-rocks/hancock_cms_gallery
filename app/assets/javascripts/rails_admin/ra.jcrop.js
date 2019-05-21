(function($) {
  $.widget("ra.jcropForm", {

    _create: function() {
      var widget = this;
      var dom_widget = widget.element;

      var thumbnailLink = dom_widget.find('.jcrop_data_value .preview');
      thumbnailLink.unbind().bind("click", function(e){
        widget._bindModalOpening(e, dom_widget.find('a.jcrop_handle').data('link'));
        return false;
      });
      dom_widget.find('[data-fileupload]').unbind("change").bind("change", function() {
        var input = this;
        var image_container = $("#" + input.id).parent().children(".preview");
        if (image_container.length > 0) {
          if (image_container[0].tagName != "img") {
            image_container.parent().removeClass("jcrop_data_value");
            image_container.remove();
          }
          image_container = $("#" + input.id).parent().children(".preview");
        }
        if (image_container.length == 0) {
          image_container = $("#" + input.id).parent().prepend($('<img />').addClass('preview')).find('img.preview');
          image_container.parent().find('img:not(.preview)').hide();
          ext = $("#" + input.id).val().split('.').pop().toLowerCase();
        }
        if (input.files && input.files[0] && $.inArray(ext, ['gif', 'png', 'jpg', 'jpeg', 'bmp']) != -1) {
          reader = new FileReader();
          reader.onload = function (e) {
            image_container.attr("src", e.target.result);
          };
          reader.readAsDataURL(input.files[0]);
          image_container.show();
        } else {
          image_container.hide();
        }
      })
    },

    _bindModalOpening: function(e, url) {
      e.preventDefault();
      widget = this;
      if($("#modal").length)
        return false;

      var dialog = this._getModal();

      setTimeout(function(){ // fix race condition with modal insertion in the dom (Chrome => Team/add a new fan => #modal not found when it should have). Somehow .on('show') is too early, tried it too.
        $.ajax({
          url: url,
          beforeSend: function(xhr) {
            xhr.setRequestHeader("Accept", "text/javascript");
          },
          success: function(data, status, xhr) {
              dialog.find('.modal-body').html(data);
              widget._bindFormEvents();
          },
          error: function(xhr, status, error) {
            dialog.find('.modal-body').html(xhr.responseText);
          },
          dataType: 'text'
        });
      },100);

    },

    _bindFormEvents: function() {
      var widget = this,
          dialog = this._getModal(),
          form = dialog.find("form"),
          saveButtonText = dialog.find(":submit[name=_save]").html(),
          cancelButtonText = dialog.find(":submit[name=_continue]").html();
      dialog.find('.form-actions').remove();

      var jcrop_options = $.extend({
        bgColor: 'white',
        bgOpacity: 0.4,
        keySupport: false,
        onSelect: widget.updateCoordinates
      }, widget.element.find('input[data-rails-admin-jcrop-options]').data('rails-admin-jcrop-options'));
      dialog.find('img.jcrop-subject').Jcrop(jcrop_options)

      form.attr("data-remote", true);
      dialog.find('.modal-header-title').text(form.data('title'));
      dialog.find('.cancel-action').unbind().click(function(){
        dialog.modal('hide');
        return false;
      }).html(cancelButtonText);

      dialog.find('.save-action').unbind().click(function(){
        form.submit();
        dialog.addClass("submiting")
        return false;
      }).html(saveButtonText);

      $(document).trigger('rails_admin.dom_ready');

      form.bind("ajax:complete", function(xhr, data, status) {
        if (status == 'error') {
          dialog.find('.modal-body').html(data.responseText);
          widget._bindFormEvents();
        } else {
          var json = $.parseJSON(data.responseText);
          var select = widget.element.find('select').filter(":hidden");

          thumb = widget.element.find('a.jcrop_handle').data('thumb') || "original";
          widget.element.find('.jcrop_data_value img').removeAttr('src').attr('src', (json.urls[thumb] || json.urls['original']) + '?' + new Date().valueOf());

          widget._trigger("success");
          dialog.modal("hide");
        }
      });
    },

    updateCoordinates: function(c) {
      var rx = 100/c.w;
      var ry = 100/c.h;
      var lw = $('img.jcrop-subject').width();
      var lh = $('img.jcrop-subject').height();
      var ratio = $('img.jcrop-subject').data('geometry').split(',')[0] / lw ;

      $('#preview').css({
        width: Math.round(rx * lw) + 'px',
        height: Math.round(ry * lh) + 'px',
        marginLeft: '-' + Math.round(rx * c.x) + 'px',
        marginTop: '-' + Math.round(ry * c.y) + 'px'
      });

      $("#crop_x").val(Math.round(c.x * ratio));
      $("#crop_y").val(Math.round(c.y * ratio));
      $("#crop_w").val(Math.round(c.w * ratio));
      $("#crop_h").val(Math.round(c.h * ratio));
    },

    _getModal: function() {
      var widget = this;
      if (!widget.dialog) {
          widget.dialog = $('' +
          '<div id="modal" class="modal fade">' +
            '<div class="modal-dialog">' +
              '<div class="modal-content">' +
                '<div class="modal-header">' +
                  '<a href="#" class="close" data-dismiss="modal">&times;</a>' +
                  '<h3 class="modal-header-title">Please wait...</h3>' +
                '</div>' +
                '<div class="modal-body">...</div>' +
                '<div class="modal-footer">' +
                  '<a href="#" class="btn cancel-action">...</a>' +
                  '<a href="#" class="btn btn-primary save-action">...</a>' +
                '</div>' +
              '</div>' +
            '</div>' +
          '</div>');
          widget.dialog.modal({
            keyboard: true,
            backdrop: false,
            show: true
          })
          .on('hidden.bs.modal', function(){
            $(document).unbind("keyup");
            widget.dialog.remove();   // We don't want to reuse closed modals
            widget.dialog = null;
          });
        $(document).unbind("keyup").bind("keyup", function(e) {
          if (e.keyCode == 13) $('#modal .modal-footer .save-action').click();     // enter
          if (e.keyCode == 27) $('#modal .modal-footer .cancel-action').click();   // esc
        });
        }
      return this.dialog;
    }
  });
})(jQuery);

$(function() {
  $('div.jcrop_type, div.hancock_image_type, div.shrine_type').jcropForm();
});

