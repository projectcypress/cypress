// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var ready;
ready = function() {
  // Also see measure_selection.js

  $('.product-test-tabs').tabs();
  $('.product-test-tabs > ul > li').removeClass("ui-corner-top");

  $('.user_tests_table').DataTable({
    searching: false,
    paging: false,
    stateSave: true, /* preserves order on reload */
    info: false,
    order: [[4, 'desc']]
  });

 $('.vendor-table').DataTable({
    searching: false,
    paging: false,
    stateSave: true, /* preserves order on reload */
    info: false
  });

  $('.vendor-table-favorite').DataTable({
    searching: false,
    paging: false,
    stateSave: true, /* preserves order on reload */
    info: false
  });


  $('#filtering_test_status_display').DataTable({
    searching: false,
    paging: false,
    stateSave: true, /* preserves order on reload */
    info: false
  });

  /* submit upload when file is attached */
  $('.multi-upload-field').on('change', function(ev) {
    $(this).parent().siblings('.multi-upload-submit').click();
  });
};

var reticulateSplines = function() {
    if ($('#display_bulk_download').length && $('#display_bulk_download').find('p:first').text().indexOf('being built') > -1) {
        $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'bulk_download' }});
    }
};

$(document).ready(ready);
$(document).on('page:load', ready);
$(document).on('page:change', reticulateSplines);
