// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {

  $('table.table').stickyRows({ rows: ['thead','.productRow']});

  $('.test_result_expanded').on('shown.bs.collapse hidden.bs.collapse', function(e) {
    console.log(e.currentTarget.prev().children('tr'));
  });

});
