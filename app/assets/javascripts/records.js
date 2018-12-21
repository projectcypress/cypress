/*global Turbolinks */

var ready;
ready = function() {
  // when the user selects a different bundle
  // just take them to the new page
  // use Turbolinks so it doesn't full refresh
  $('label.btn-checkbox input[name="bundle_id"]').on('change', function() {
    var bundle_id = $(this).val();
    Turbolinks.visit("/bundles/"+bundle_id+"/records");
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
