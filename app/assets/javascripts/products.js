// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var ready;
ready = function() {
  // Also see measure_selection.js

  $('.product-test-tabs').tabs();

  $('#measure_tests_table').DataTable({
    searching: false,
    paging: false,
    stateSave: true, /* preserves order on reload */
    info: false
  });
};

reticulateSplines = function() {
    if ($('#display_bulk_download').length) {
        $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'bulk_download' }});
    }

    if ($('#display_measure_tests_table').length) {
      $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'measure_tests_table' }});
    }

    if ($('#display_filtering_test_status_display').length) {
      $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'filtering_test_status_display' }});
    }
}

$(document).ready(ready);
$(document).on('page:load', ready);
$(document).on('page:change', reticulateSplines);
