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

$(document).ready(ready);
$(document).on('page:load', ready);
