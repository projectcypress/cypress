// these pieces should run only once, at page load
var ready_run_once;
ready_run_once = function() {

  // Enable changing measures
  $('#save_options').find('button.confirm').on('click', function (event) {
    event.preventDefault();
    $('.btn-danger').attr('disabled', false);
  });

};

$(document).ready(ready_run_once);
$(document).on('page:load', ready_run_once);
