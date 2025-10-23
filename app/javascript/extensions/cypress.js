import $ from "jquery2";

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