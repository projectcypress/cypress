/*global Turbolinks */

var ready;
ready = function() {
  // when the user selects a different bundle
  // just take them to the new page
  // use Turbolinks so it doesn't full refresh
  $('label.bundle-checkbox input[name="bundle_id"]').on('change', function() {
    var bundle_id = $(this).val();
    Turbolinks.visit("/bundles/"+bundle_id+"/records");
  });
  $('label.vendor-checkbox input[name="bundle_id"]').on('change', function() {
    var bundle_id = $(this).val();
    Turbolinks.visit("?bundle_id="+bundle_id);
  });

  // This is its own unique checkbox panel danger class, so should not affect
  // behavior of other danger panels
  $('.delete_vendor_patients_form input:checkbox').on('change', function() {
    var checked = $('.delete_vendor_patients_form input:checkbox:checked');
    if (checked.length > 0){
      // Make remove panel visable
      $('.checkbox-danger-panel').show();
    }
    else{
      // Make remove panel invisible
      $('.checkbox-danger-panel').hide();
    }
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
