//////////////////////
// Helper functions //
//////////////////////

function CheckMany(group) {
  if (group == 'all') {
    $('.measure-list .measure-checkbox:not(:checked)').prop('checked', true).change();
  } else {
    $('.measure-list .measure-checkbox')
      .filter(':not([data-measure-type='+group+'])').prop('checked', false).change().end()
      .filter('[data-measure-type='+group+']').prop('checked', true).change();
  }
}

function ToggleCustomSelection(task) {
  var shouldHideView = function() {
    if (task == 'close' && !$('.select-measures').hasClass('hidden')) {
      return true;
    } else if (task == 'open' && $('.select-measures').hasClass('hidden')) {
      return false;
    }
  }

  if (shouldHideView() !== undefined) {
    $('.select-measures').toggleClass('hidden', shouldHideView());
  }
}


function UpdateGroupSelections(event) {
  var measure_category = $(event.currentTarget).attr('data-category');
  var $groupChecks = $('.measure-list .measure-checkbox[data-category='+ measure_category +']');

  var groupIsSelected = !$groupChecks.filter(':not(:checked)').length; // true if none are unchecked

  $('.measure_group_all[id='+ measure_category +']').prop('checked', groupIsSelected);

  // update the selected counts in the tabs
  var number_checked = $groupChecks.filter(':checked').length;

  $('.sidebar').find('[href*='+ measure_category +'] .selected-number')
    .html(function() {
      if (number_checked > 0) {
        return number_checked + '<i aria-hidden="true" class="fa fa-fw fa-check"></i>'
      } else { return '' }
    });

  $('.select-measures .panel-title .selected-number')
    .html(function() {
      if ($('.measure-list .measure-checkbox:checked').length > 0) {
        return $('.measure-list .measure-checkbox:checked').length + '<i aria-hidden="true" class="fa fa-fw fa-check"></i>'
      } else { return '(0)' }
    });

}

function UpdateMeasureSet(bundle_id) {

  $("#measure_selection_section").empty();
      var ids = [];
      // get the measures for this type of test
      $.ajax({
          url: "/bundles/" + bundle_id + "/measures/grouped",
          type: "GET",
          dataType: "html",
          success: function(data, textStatus, xhr) {
            $("#measure_selection_section").html(data);
            ready_run_on_refresh_bundle();
          },
          error: function(xhr, textStatus, err) {
            alert("Sorry, we can't currently produce measures for that bundle. " + err);
          }
      });
}




// these pieces need to run every time the bundle is changed
// (they act on the measures which have been reloaded by ajax,
//  not the controls which are fixed)
var ready_run_on_refresh_bundle;
ready_run_on_refresh_bundle = function() {

  // Checking a group of measures
  $('.measure_group_all').on('change', function () {
    $(this).closest('.measure_group').find('.measure-checkbox[data-category='+$(this).attr('id')+']')
      .prop('checked', this.checked).change().trigger('groupclick');
  });

  // Checking an individual measure
  $('.measure-checkbox').on('change', this, UpdateGroupSelections);

  ///////////////////////
  // Do things on load //
  ///////////////////////

  // Instantiate tabs
  $('#measure_tabs').tabs().addClass("ui-tabs-vertical ui-helper-clearfix");
  $('#measure_tabs li').removeClass("ui-corner-top").addClass("ui-corner-left");

  // Trigger change events for already-checked inputs
  $('.measure-list .measure-checkbox:checked').trigger('change');
  $('input[name="product[measure_selection]"]:checked').trigger('change');


};

// these pieces should run only once, at page load
var ready_run_once;
ready_run_once = function() {



  ////////////////////////////
  // Set up event listeners //
  ////////////////////////////
  // make sure front-end form validations happen when needed
  $('form[data-parsley-validate]').find('input[type="checkbox"], input[type="radio"]').on('click groupclick', function() {
    $(this).parsley().validate(); // force re-validation
    // sometimes when a field is found to be invalid, it doesn't
    // trigger further validations on its own. so we do this manually.
    // set on click and custom groupclick event to avoid triggering this
    // every time inputs are changed programmatically
  });

  // Checking a radio button indicating measure selection
  $('.btn-checkbox input[name="product[measure_selection]"]').on('change', function() {
    if ($(this).attr('disabled') != true) {
      var selection = $(this).val();

      if (selection == 'custom') {
        ToggleCustomSelection('open');
      }
      else {
        ToggleCustomSelection('close');
        CheckMany(selection);
      }
    }
  });


  // Enable changing measures
  $('#measures_options').find('button.confirm').on('click', function (event) {
    event.preventDefault();
    $('.measure-list [type="checkbox"]').attr('disabled', false);
    $('input[name="product[measure_selection]"]').attr('disabled', false);
    $('input[name="product[measure_selection]"]').closest('.radio').removeClass('disabled');
    $(event.currentTarget).closest('alert').find('.close').click();
  });

  // Changing the bundle
  $('.btn-checkbox input[name="product[bundle_id]"]').on('change', function() {
    if ($(this).attr('disabled') != true) {
      var selection = $(this).val();
      UpdateMeasureSet(selection);
    }
  });

  // run this piece once too
  ready_run_on_refresh_bundle();
};

$(document).ready(ready_run_once);
$(document).on('page:load', ready_run_once);
