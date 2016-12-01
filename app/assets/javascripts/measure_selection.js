//////////////////////
// Helper functions //
//////////////////////

function CheckMany(group) {
  if (group == 'all') {
    $('.measure-group .measure-checkbox:not(:checked)').prop('checked', true).change();
  } else {
    $('.measure-group .measure-checkbox')
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

  if (typeof shouldHideView() !== "undefined") {
    $('.select-measures').toggleClass('hidden', shouldHideView());
  }
}

function UpdateGroupSelections(event) {
  var measure_category = $(event.currentTarget).attr('data-category');
  var $groupChecks = $('.measure-group .measure-checkbox[data-category='+ measure_category +']');

  var groupIsSelected = !$groupChecks.filter(':not(:checked)').length; // true if none are unchecked

  $('.measure-group-all[id='+ measure_category +']').prop('checked', groupIsSelected);

  // update the selected counts in the tabs
  var number_checked = $groupChecks.filter(':checked').length;

  $('#measure_tabs .ui-tabs-nav').find('[href*='+ measure_category +'] .selected-number')
    .html(function() {
      if (number_checked > 0) {
        return number_checked + '<i aria-hidden="true" class="fa fa-fw fa-check"></i>'
      } else { return '' }
    });

  $('.select-measures .panel-title .selected-number')
    .html(function() {
      if ($('.measure-group .measure-checkbox:checked').length > 0) {
        return $('.measure-group .measure-checkbox:checked').length + '<i aria-hidden="true" class="fa fa-fw fa-check"></i>'
      } else { return '(0)' }
    });

}

// This function is called whenever a successful measure filter ajax request is made.
// It hides the measures that do not match the search parameters.
function filterVisibleMeasures(searchbox, returned_measures) {
  // Collect up all measure checkboxes and their accompanying description
  var measures = $('.measure-group .checkbox')

  // If the searchbox is empty, show everything. This fixes the "select all"
  // option from being permantently hidden
  if(searchbox.val() == "") {
    $.each(measures, function() {
      $(this).show()
    });
  } else {
    // If the searchbox is not empty then filter measures based on the returned results
    $.each(measures, function() {
      if($.inArray(this.id, returned_measures) >= 0) {
        $(this).show()
      } else {
        $(this).hide()
      }
    });
  }
}

// This function is called whenever a successful measure filter ajax request is made.
// It hides the measure tabs that do not match the search parameters.
function filterVisibleMeasureTabs(searchbox, measure_tabs_response) {

  // Collect up all measure tabs
  var measure_tabs = $("[role='tablist'] [role='tab']")

  // Iterate over all measure tabs and remove ones that were not included in filtered measure
  // tabs in the measure_tabs_response variable.
  $.each(measure_tabs, function() {
    var current_tab_name = $(this).attr('aria-controls')

    if(current_tab_name in measure_tabs_response) {
      $(this).show()
      // Save the children of the element before changing the contents
      var $cache = $(this).contents('a').children();
      $(this).contents('a').text(measure_tabs_response[current_tab_name]).append($cache)
    } else {
      $(this).hide()
    }
  });

  // If the current ui tab is not visible then grab the first one that is and activate it
  if(!($("[role='tablist'] [role='tab'].ui-tabs-active").is(':visible'))) {
    measure_tabs.find(':visible:first').first().click()
  }
}

function UpdateMeasureSet(bundle_id) {

  $("#measure_selection_section").empty();
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
  $('.measure-group-all').on('change', function () {
    $(this).closest('.measure-group').find('.measure-checkbox[data-category='+$(this).attr('id')+']')
      .prop('checked', this.checked).change().trigger('groupclick');
  });

  // Checking an individual measure
  $('.measure-checkbox').on('change', this, UpdateGroupSelections);

  ///////////////////////
  // Do things on load //
  ///////////////////////

  // Instantiate tabs
  $('#measure_tabs').tabs().addClass("ui-tabs-vertical ui-helper-clearfix");
  $('#measure_tabs > ul > li').removeClass("ui-corner-top");

  // Trigger change events for already-checked inputs
  $('.measure-group .measure-checkbox:checked').trigger('change');
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
    $('.measure-group [type="checkbox"]').attr('disabled', false);
    $('input[name="product[measure_selection]"]').attr('disabled', false);
    $('input[name="product[measure_selection]"]').closest('.radio').removeClass('disabled');
    $(event.currentTarget).closest('alert').find('.close').click();
  });

  $('.clear-measures-btn').on('click', function(event) {
    $('.measure-group .measure-checkbox').prop('checked', false).change();
    this.blur();
    // $('clear-measures-btn').setAttribute("aria-pressed", false);
  });


  // Changing the bundle
  $('.btn-checkbox input[name="product[bundle_id]"]').on('change', function() {
    if ($(this).attr('disabled') != true) {
      var selection = $(this).val();
      UpdateMeasureSet(selection);
    }
  });

  // Disable enter key from submitting the add or edit product form when in the measure search box
  $('#product_search_measures').keypress(function(event) {
    if (event.keyCode == 13) {
      return false;
    }
  });

  // Filter the available measures when a user types in the measure filter box
  $('#product_search_measures').on('keyup', function () {
    // Fetch the currently selected bundle from the list on the top of the page.
    var bundle_id = $('input[name="product[bundle_id]"]:checked').val()
    // Remove or urlencode any special characters from the search query
    var current_search = encodeURIComponent($('#product_search_measures').val().replace(/[!'()*]/g, ""))
    // Searchbox is #product_search_measures which is currently the parent.
    var searchbox = $(this)

    $.ajax({
      url: "/bundles/" + bundle_id + "/measures/filtered/" + current_search,
      type: "GET",
      dataType: "json",
      success: function(data, textStatus, xhr) {
        filterVisibleMeasures(searchbox, data.measures)
        filterVisibleMeasureTabs(searchbox, data.measure_tabs)
      }
    });
  });

  // run this piece once too
  ready_run_on_refresh_bundle();
};

$(document).ready(ready_run_once);
$(document).on('page:load', ready_run_once);
