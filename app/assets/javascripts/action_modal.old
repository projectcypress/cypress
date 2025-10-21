
var ready;
ready = function() {

  /* edit text in modal with text from specific object form */
  $(document).on('show.bs.modal', '#action_modal', function(e) {
    $(this).find('.modal-content .modal-title').text($(e.relatedTarget).attr('data-title'));
    $(this).find('.modal-body p.warning_message').text($(e.relatedTarget).attr('data-message'));
    $(this).find('.modal-body span.object_type').text($(e.relatedTarget).attr('data-object-type'));
    $(this).find('.modal-body strong.object_name').text($(e.relatedTarget).attr('data-object-name'));
    $(this).find('.modal-body span.object_action').text($(e.relatedTarget).attr('data-object-action'));
    $(this).find('.modal-body input.confirm_object_name').attr('placeholder', $(e.relatedTarget).attr('data-object-type'));

    /* set data-form for modal to correct form */
    $('#modal_confirm_remove').data('form', $(e.relatedTarget).closest('form'));
  });

  /* enable the remove button if the input field matches the object name */
  $(document).on('keyup', '#action_modal input.confirm_object_name', function(e) {
    if ($(this).parent().siblings('p').children('strong.object_name').text() == $(this).val()) {
      $('#modal_confirm_remove').attr('disabled', false);

      if(e.keyCode == 13)
      {
         // simulate clicking the button if they press enter
         $('#modal_confirm_remove').click();
      }

    } else {
      $('#modal_confirm_remove').attr('disabled', true);
    }
  });

  $(document).on('hidden.bs.modal', '#action_modal', function () {
    $(this).find('input.confirm_object_name').val('');
    $('#modal_confirm_remove').attr('disabled', true);
  })

  /* submit deletion of specific object */
  $(document).on('click', '#modal_confirm_remove', function() {
    // all checked checkbox type inputs within a delete_vendor_patient_form class
    // collect ids
    var checked = $('.delete_vendor_patients_form input:checkbox:checked')
    if(checked.length>0){
      var ids = $.map(checked, function(val, i){
        return $(val).attr('id');
      });
      var input = $("<input>")
                 .attr("type", "hidden")
                 .attr("name", "patient_ids").val(ids);
      $(this).data('form').append(input);
    }
    $(this).data('form').submit();
  });

};

$(document).ready(ready);
$(document).on('page:load page:restore page:partial-load', ready);
