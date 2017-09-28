
var ready;
ready = function() {

  /* edit text in modal with text from specific object form */
  $('#action_modal').on('show.bs.modal', function(e) {
    $(this).find('.modal-content .modal-title').text($(e.relatedTarget).attr('data-title'));
    $(this).find('.modal-body p.warning_message').text($(e.relatedTarget).attr('data-message'));
    $(this).find('.modal-body span.object_type').text($(e.relatedTarget).attr('data-object-type'));
    $(this).find('.modal-body strong.object_name').text($(e.relatedTarget).attr('data-object-name'));
    $(this).find('.modal-body span.object_action').text($(e.relatedTarget).attr('data-object-action'));
    $(this).find('.modal-body input.confirm_object_name').attr('placeholder', $(e.relateTarget).attr('data-object-type'));

    /* set data-form for modal to correct form */
    $('#modal_confirm_remove').data('form', $(e.relatedTarget).closest('form'));
  });

  /* enable the remove button if the input field matches the object name */
  $('#action_modal input.confirm_object_name').keyup(function(e) {
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

  $('#action_modal').on('hidden.bs.modal', function () {
    $(this).find('input.confirm_object_name').val('');
    $('#modal_confirm_remove').attr('disabled', true);
  })

  /* submit deletion of specific object */
  $('#modal_confirm_remove').on('click', function() {
    $(this).data('form').submit();
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);
