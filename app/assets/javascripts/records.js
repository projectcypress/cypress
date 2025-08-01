/*global Turbolinks */

var ready;
function changePanel(){
  var checked = $('input:checked');
  if (checked.length > 0){
    // Make remove panel visable
    $('.checkbox-danger-panel').toggleClass('d-none');
  }
  else{
    // Make remove panel invisible
    $('.checkbox-danger-panel').toggleClass('d-none');
  }
}
ready = function() {
  // when the user selects a different bundle
  // just take them to the new page
  // use Turbolinks so it doesn't full refresh
  $(document).on('change', 'input[name="bundle_id"]', function() {
    var bundle_id = $(this).val();
    if ($(this).next('.bundle-checkbox').length > 0) {
      Turbolinks.visit("/bundles/"+bundle_id+"/records");
    }
  });
  $(document).on('change', 'input[name="bundle_id"]', function() {
    var bundle_id = $(this).val();
    if ($(this).next('.vendor-checkbox').length > 0) {
      Turbolinks.visit("?bundle_id="+bundle_id);
    }
  });

  // This is its own unique checkbox panel danger class, so should not affect
  // behavior of other danger panels
  $(document).on('change', '.delete_vendor_patients_form input:checkbox', changePanel);

  $(document).on('click', '#vendor-patient-select-all', function() {
    // alert("alert!");
    var button_font = $(this).find( "i" );
    var checkbox = $('.delete_vendor_patients_form input:checkbox');
    if ($(this).val() == "unchecked"){
      checkbox.each(function () {
        $(this).prop("checked", true);
      });
      button_font.removeClass("fa-square");
      button_font.addClass("fa-check-square");
      $(this).prop('title', "Unselect All");
      $('#vendor-patient-select-all-text').text("Unselect All");
      $(this).val("checked");
    }else{
      checkbox.each(function () {
        $(this).prop("checked", false);
      });
      button_font.removeClass("fa-check-square");
      button_font.addClass("fa-square");
      $(this).prop('title', "Select All");
      $('#vendor-patient-select-all-text').text("Select All");
      $(this).val("unchecked");
    }
    changePanel();
  });
}

$(document).ready(ready);
$(document).on('page:load page:restore page:partial-load', ready);
