import $ from "jquery2";
import "jquery-ui"
import "datatables"

function setCheckboxDisabledNoUncheck(element, state) {
  var children = $(element).closest('input.form-check-input').find('*').addBack();
  if (state) {
    $(children).addClass('disabled');
    $(children).prop('disabled', true);
  }
  else {
    $(children).removeClass('disabled');
    $(children).prop('disabled', false);
  }
}

function setElementHidden(element, state) {
  if (state) {
    $(element).addClass('hidden');
    $(element).prop('hidden', true);
  }
  else {
    $(element).removeClass('hidden');
    $(element).prop('hidden', false);
  }
}

// Product Form
// $(document).ready(ready_run_once);
// $(document).on('page:load', ready_run_once);
export function initializeJqueryCvuRadio() { 
  $('.form-check input[name="product[cvuplus]"]').on('change', function() {
    var cvuplus_checked = ($(this).val() == 'true');
    if ($(this).attr('disabled') != 'disabled') {
      setCheckboxDisabledNoUncheck('#product_vendor_patients', !cvuplus_checked);
      setCheckboxDisabledNoUncheck('#product_bundle_patients', !cvuplus_checked);
      setCheckboxDisabledNoUncheck('#product_c1_test', cvuplus_checked);
      setCheckboxDisabledNoUncheck('#product_c2_test', cvuplus_checked);
      setCheckboxDisabledNoUncheck('#product_c3_test', cvuplus_checked);
      setCheckboxDisabledNoUncheck('#product_c4_test', cvuplus_checked);
    }
    setElementHidden('#bundle_options', !cvuplus_checked);
    setElementHidden('#certification_options', cvuplus_checked);
    setElementHidden('#certification_edition', cvuplus_checked);
  });
}


// $(document).ready(ready);
// $(document).on('page:load', ready);
export function initializeProductTable() { 
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
  $(document).on('change', '.multi-upload-field', function(ev) {
    $(this).parent().siblings('.multi-upload-submit').click();
  });
};

// $(document).on('page:change', reticulateSplines);
export function reticulateSplines() { 
    if ($('#display_bulk_download').length && $('#display_bulk_download').find('p:first').text().indexOf('being built') > -1) {
        $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'bulk_download' }});
    }
};