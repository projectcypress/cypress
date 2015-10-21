// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

/* This is something that must be done so that turbolinks will ready the document

var ready;
ready = function() {

  ...your javascript goes here...

};

$(document).ready(ready);
$(document).on('page:load', ready);

*/

var ready;
ready = function() {

  /* get number of poc's and vendor name from HTML */
  var poc_index = parseInt($('#poc_counter').text());
  var vendor_name = $("#popup_vendor_name").text();

  $("#add_vendor_form")

    /* add a point of contact field set */
    .on('click', '#add_poc_field_set_button', function() {

      var template = $('#poc_template');

      var clone = template.clone()
                  .removeClass('hide')
                  .removeAttr('id')
                  .attr('data-poc-index', poc_index)
                  .insertBefore(template);

      /* replace all fields in newly generated POC field set with appropriate names and id fields */
      clone.find('[name = "name"]').attr('name', 'vendor[pocs_attributes][' + poc_index + '][name]').end()
           .find('[name = "contact_type"]').attr('name', 'vendor[pocs_attributes][' + poc_index + '][contact_type]').end()
           .find('[name = "email"]').attr('name', 'vendor[pocs_attributes][' + poc_index + '][email]').end()
           .find('[name = "phone"]').attr('name', 'vendor[pocs_attributes][' + poc_index + '][phone]').end()
           .find('[id = "template_remove_label"]').attr('for', 'vendor_pocs_attributes_' + poc_index + '__destroy').attr('id', '').end()
           .find('[id = "template_remove_hidden_input"]').attr('name', 'vendor[pocs_attributes][' + poc_index + '][_destroy]').attr('id', '').end()
           .find('[id = "template_remove_checkbox"]').attr('id', 'vendor_pocs_attributes_' + poc_index + '__destroy').attr('name', 'vendor[pocs_attributes][' + poc_index + '][_destroy]').end()

        poc_index++;

    })

    /* remove poc button hides poc field set. hidden poc's will not be saved to the database */
    .on('click', '.remove_label', function() {

      $(this).parent().parent('.form-group').addClass('hide');

    });

    /* add a single poc field set for a new vendor */
    if (poc_index == 0) {
      $('#add_poc_field_set_button').click();
    }

};

$(document).ready(ready);
$(document).on('page:load', ready);
