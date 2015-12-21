
var ready;
ready = function() {
  $("#submit-upload").click(function(event) {
    event.preventDefault();
    $("#new_test_execution").submit();
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);