var ready;
ready = function() {

  var vendor_name = $("#in_popup_object_name").text();

  $('#in_popup_text_field').keyup(function() {
    if (vendor_name == $(this).val()) {
      $("#in_popup_remove_button").prop("disabled", false);
    } else {
      $("#in_popup_remove_button").prop("disabled", true);
    }
  })

};

$(document).ready(ready);
$(document).on('page:load', ready);