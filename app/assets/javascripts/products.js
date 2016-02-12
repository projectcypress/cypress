// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var ready;
ready = function() {

  // Function to manage the checkbox controlling a given measure group
  var adjustMeasureGroupCheckbox = function(group_checkbox) {
    // find checkboxes for all measures in the group
    var $group_measures = $(group_checkbox).closest('.measure_group').find('.measure-checkbox');
    // set checked property of this input based on whether everything in the group is checked
    $(group_checkbox).prop('checked', $group_measures.filter('input:checkbox').length == $group_measures.filter('input:checkbox:checked').length);
  }

  // Add event listener to toggle styling on selected checkboxes
  $('.btn-checkbox input:checkbox').on('change', function() {
    $(this).parent().toggleClass('active', $(this).prop('checked'));
  });

  // Add event listener for selecting all measures in a group
  $('.measure_group_all').on('change', function () {
    var $group_measures = $(this).closest('.measure_group').find('.measure-checkbox');

    if (this.checked) {
      // check unchecked measures in the group and trigger change event
      $group_measures.filter('.measure-checkbox:not(:checked)').prop('checked', this.checked).change();
    } else {
      // uncheck checked measures in the group and trigger change event
      $group_measures.filter('.measure-checkbox:checked').prop('checked', this.checked).change();
    }
  });

  // Add event listener for selecting individual measures
  $('.measure-list .measure-checkbox').on('change', function() {
    if (this.checked) {
      // clone checked measure and put into selected measure list
      $cloned_checkbox = $(this).closest('div.checkbox').clone(true);
      $cloned_checkbox.find('label').addClass('btn btn-checkbox active');
      $cloned_checkbox.appendTo('.selected-measure-list');
    } else {
      // remove element from selected measure list and uncheck from main measure list
      $('.selected-measure-list .measure-checkbox').filter('#' + this.id).closest('div.checkbox').remove();
      $('.measure-list .measure-checkbox').filter('#' + this.id).prop('checked', this.checked);
    }

    var $group_checkbox = $('.measure-list .measure-checkbox').filter('#' + this.id).closest('.measure_group').find('.measure_group_all');
    adjustMeasureGroupCheckbox($group_checkbox[0]);
  });

  // Instantiate tabs
  $('#measure_tabs').tabs().addClass("ui-tabs-vertical ui-helper-clearfix");
  $('#measure_tabs li').removeClass("ui-corner-top").addClass("ui-corner-left");

  $('.product-test-tabs').tabs();

  // Set up appearance of inputs on initial load
  $('.btn-checkbox input:disabled').parent().addClass('disabled');
  $('.btn-checkbox input:checked:not(:disabled)').trigger('change');
  $('.measure-list .measure-checkbox:checked').trigger('change');
  $('.measure_group_all').each(function() {
    adjustMeasureGroupCheckbox(this);
  });

  // Let user reset all tests on a product
  $('.measure-selection .warning-overlay input#confirm_edit_risk').keyup(function() {
    if ($('.measure-selection .warning-overlay strong.risk_text').text() == $(this).val()) {
      $('.measure-selection .warning-overlay').remove();
      $('.select-measures input[type="checkbox"]').prop('disabled', false);
    }
  });

  $('#measure_tests_table').DataTable({
    searching: false,
    paging: false,
    stateSave: true, /* preserves order on reload */
    info: false
  });
};

$(document).ready(ready);
$(document).on('page:load', ready);
