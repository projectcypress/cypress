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

var initializeTestExecutionResults = function() {
  // activate the tabs
  $(".file-error-tabs").tabs().addClass("ui-tabs-vertical ui-helper-clearfix").removeClass("ui-widget").removeClass('hidden');
  $(".file-error-tabs > ul > li").removeClass("ui-corner-top");
  $(".xml-error-tabs").each(function() {
    // disable tabs with no errors and set active tab
    var disabledTabs = [];
    var enabledTabs = [];

    $(this).find("li").each(function(index) {
      if ($(this).find('span').text() == "(0)") {
        disabledTabs.push(index);
      } else {
        enabledTabs.push(index);
      }
    });

    $(this).tabs({ "active": enabledTabs[0], "disabled": disabledTabs });
  });
  $(".xml-error-tabs > ul > li").removeClass("ui-corner-top");

  // set up interactions for the XML views
  $(".xml-view").each(function() {
    /* link subnav with the execution_error_link s */
    var $error_links = $(this).parent().find("a.execution_error_link");

    if ($error_links.length) {
      $(this).fixedHeader();

      var targets = jQuery.map($error_links, function(el, i){
        return "[href='" + $(el).attr('href') + "']"
      });

      var navigation = $(this).find(".xml-nav").navigator({targets: targets.join(), action: show_error_popup_and_jump});

      $error_links.on('click', function(event) {
        var href = $(this).attr('href');
        show_error_popup_and_jump(href);
        navigation.data('navigator').setIndex(href);
        return false;
      });
    }
  });

  // enable each error popover
  //$('.error-popup-btn').popover();

  /* change 'view' and 'hide' text for popover buttons */
  $('.error-popup-btn').on('show.bs.popover', function () {
    this.children[1].innerText = this.children[1].innerText.replace('view', 'hide');
  });
  $('.error-popup-btn').on('hide.bs.popover', function () {
    this.children[1].innerText = this.children[1].innerText.replace('hide', 'view');
  });

}

function show_error_popup_and_jump(href) {
  if ($(href)) {
    $('button.error-popup-btn').popover('hide'); /* hide all error popovers before showing the new one */

    var scroll_time = 300;      /* (milisec) time it takes to scroll from one error popover to another */
    var height_buffer = 20;     /* number of pixels between the xml_nav_bar and the error after done scrolling */

    var height_of_xmlnav_div = $('.xml-nav').outerHeight();
    var height_of_error_div = $(href).siblings('.error').outerHeight();
    var pixels_down_page = height_of_xmlnav_div + height_buffer + height_of_error_div; /* number of pixels down the page the error will apear after scrolling */

    /* scroll to error popover */
    $('html,body').animate({ scrollTop: $(href).offset().top - pixels_down_page }, { duration: scroll_time, easing: 'swing'}).promise().done(function() {
      $('button.' + href.replace('#', '')).popover('toggle');           /* show popover for button with matching error id class */

      var $list_item = $('li.' + href.replace('#', ''));
      if ($list_item.length) {
        $list_item.effect( "highlight", {}, 2000 ); /* temporarily highlight the error if there are a list of errors in the popover */
      }
    });
  }
}

var approachingBottomOfPage, loadNextPageAt, nextPage, nextPageFnRunning, viewMore, checkAndLoad;

nextPageFnRunning = false;
loadNextPageAt = 3000;

approachingBottomOfPage = function() {
  return $(window).scrollTop() > $(document).height() - $(window).height() - loadNextPageAt;
};

nextPage = function() {
  var loadingMore, url;
  viewMore = $('#view-more');
  loadingMore = $('#loading-more');
  url = viewMore.find('a').attr('href');
  if (nextPageFnRunning || !url) {
    return;
  }
  viewMore.hide();
  loadingMore.show();
  nextPageFnRunning = true;
  return $.ajax({
    url: url,
    method: 'GET',
    dataType: 'script'
  }).always(function() {
    nextPageFnRunning = false;
    viewMore.show();
    return loadingMore.hide();
  });
};

// Checks to see if we are close to the bottom of the page and if we are load more measures
checkAndLoad = function() {
  if (approachingBottomOfPage()) {
    return nextPage();
  }
};

function escapeCSS(str) {
  return str.replace(/[!"#$%&'()*+,./:;<=>?@[\\\]^`{|}~]/g, "\\$&");
}

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

// Allows the enabling or disabling of a checkbox by passing true or false
// as the second parameter. True means disabled and false means enabled.
function setCheckboxDisabled(element, state) {
  var children = $(element).closest('input.form-check-input').find('*').addBack();
  if (state) {
    $(children).addClass('disabled');
    $(children).prop('disabled', true);
    $(element).prop('checked', false);
  }
  else {
    $(children).removeClass('disabled');
    $(children).prop('disabled', false);
  }
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

function CheckMany(group) {
  if (group == 'all') {
    $('.measure-group .measure-checkbox:not(:checked)').prop('checked', true).change()
      .filter('[data-category=Retired]').prop('checked', false).change();
  } else {
    $('.measure-group .measure-checkbox')
      .filter(':not([data-measure-type='+group+'])').prop('checked', false).change().end()
      .filter('[data-measure-type='+group+']').prop('checked', true).change()
      .filter('[data-category=Retired]').prop('checked', false).change();
  }
}

function ToggleCustomSelection(task) {
  var shouldHideView = function() {
    if (task == 'close' && !$('.select-measures').hasClass('d-none')) {
      return true;
    } else if (task == 'open' && $('.select-measures').hasClass('d-none')) {
      return false;
    }
  }

  if (typeof shouldHideView() !== "undefined") {
    $('.select-measures').toggleClass('d-none', shouldHideView());
  }
}

function UpdateGroupSelections(event) {
  var measure_category = escapeCSS($(event.currentTarget).attr('data-category'));
  var $groupChecks = $('.measure-group .measure-checkbox[data-category='+ measure_category +']');

  var groupIsSelected = !$groupChecks.filter(':not(:checked)').length; // true if none are unchecked

  $('.measure-group-all[id='+ measure_category +']').prop('checked', groupIsSelected);

  // update the selected counts in the tabs
  var number_checked = $groupChecks.filter(':checked').length;

  $('#measure_tabs .ui-tabs-nav').find('[href*='+ measure_category +'] .selected-number')
    .html(function() {
      if (number_checked > 0) {
        return number_checked + '<i aria-hidden="true" class="fas fa-fw fa-check"></i>'
      } else { return '' }
    });

  $('.select-measures .card-title .selected-number')
    .html(function() {
      if ($('.measure-group .measure-checkbox:checked').length > 0) {
        return $('.measure-group .measure-checkbox:checked').length + '<i aria-hidden="true" class="fas fa-fw fa-check"></i>'
      } else { return '(0)' }
    });

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

function HookupProductSearch() {
  // Get all bundles listed on the page
  var bundles = $('input[name="product[bundle_id]"]')
  // Fetch the currently selected bundle from the list on the top of the page.
  // If there are multiple bundles then grab only the one that is checked.
  var bundle_id = bundles.filter(':checked').val() || bundles.val()
  // Remove or urlencode any special characters from the search query
  var current_search = encodeURIComponent($('#product_search_measures').val().replace(/[!'()*]/g, ""))
  // Searchbox is #product_search_measures which is currently the parent.
  var searchbox = $(this)

  var ajaxReq, timer
  clearTimeout(timer)
  if (ajaxReq) ajaxReq.abort();

  timer = setTimeout(function(){
    ajaxReq = $.ajax({
      url: "/bundles/" + bundle_id + "/measures/filtered/" + current_search,
      type: "GET",
      dataType: "json",
      success: function(data, textStatus, xhr) {
        ajaxReq = null
        filterVisibleMeasures(searchbox, data.measures)
        filterVisibleMeasureTabs(searchbox, data.measure_tabs)
      }
    });
  }, 200);
}

function lookupLabelFunction(index) {
// Declare variables
  var input, checkbox;
  input = document.getElementById("code"+index);
  if(input !== null){
    checkbox = document.getElementById("product_test_checked_criteria_attributes_"+index+"_negated_valueset");
    if(checkbox.checked == true){
      $("div#code"+index).hide()
      $("div#vs"+index).show()
    } else {
      $("div#vs"+index).hide()
      $("div#code"+index).show()
    }
  }
}

// these pieces need to run every time the bundle is changed
// (they act on the measures which have been reloaded by ajax,
//  not the controls which are fixed)
var ready_run_on_refresh_bundle;
ready_run_on_refresh_bundle = function() {

  // Checking a group of measures
  $('.measure-group-all').on('change', function () {
    $(this).closest('.measure-group').find('.measure-checkbox[data-category='+ escapeCSS($(this).attr('id')) +']')
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
  $('input[name="product[cvuplus]"]:checked').trigger('change')

  // Disable enter key from submitting the add or edit product form when in the measure search box
  $('#product_search_measures').keypress(function(event) {
    if (event.keyCode == 13) {
      return false;
    }
  });

  // Filter the available measures when a user types in the measure filter box
  $('#product_search_measures').on('keyup', HookupProductSearch);
};

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

export function initializeMeasureSelection() {
  ////////////////////////////
  // Set up event listeners //
  ////////////////////////////
  // make sure front-end form validations happen when needed
  //$('form[data-parsley-validate]').find('input[type="checkbox"], input[type="radio"]').on('click groupclick', function() {
    //$(this).parsley().validate(); // force re-validation
    // sometimes when a field is found to be invalid, it doesn't
    // trigger further validations on its own. so we do this manually.
    // set on click and custom groupclick event to avoid triggering this
    // every time inputs are changed programmatically
  //});

  // Checking a radio button indicating measure selection
  $('.form-check input[name="product[measure_selection]"]').on('change', function() {
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
  $('#measures_options').find('button').on('click', function (event) {
    event.preventDefault();
    $('.measure-group [type="checkbox"]').attr('disabled', false);
    $('input[name="product[measure_selection]"]').attr('disabled', false);
    $('input[name="product[measure_selection]"]').closest('.radio').removeClass('disabled');
    $(event.currentTarget).closest('alert').find('.close').click();
  });

  $(document).on('click', '.clear-measures-btn', function(event) {
    $('.measure-group .measure-checkbox').prop('checked', false).change();
    this.blur();
    // $('clear-measures-btn').setAttribute("aria-pressed", false);
  });


  // Changing the bundle
  $('.form-check input[name="product[bundle_id]"]').on('change', function() {
    if ($(this).attr('disabled') != true) {
      var selection = $(this).val();
      UpdateMeasureSet(selection);
    }
  });

  // Check Duplicate Records on C2 Test check
  $('.form-check input[name="product[c2_test]"]').on('change', function() {
    if ($(this).attr('disabled') != true) {
      var c2_checked = $(this).prop('checked');
      setCheckboxDisabled('#product_duplicate_patients', !c2_checked);
      $('.form-check-input#product_duplicate_patients').prop('checked', c2_checked);
    }
  });

  // Check Duplicate Records on CVU+ check
  $('.form-check input[name="product[cvuplus]"]').on('change', function() {
    if ($(this).attr('disabled') != true) {
      var cvu_plus = $(this).val();
      var c2_checked = $('input[name="product[c2_test]"]')[1].checked
      setCheckboxDisabled('#product_duplicate_patients', (cvu_plus == 'false' && !c2_checked));
      $('.form-check-input#product_duplicate_patients').prop('checked', cvu_plus == 'true' || c2_checked);
    }
  });

  // run this piece once too
  ready_run_on_refresh_bundle();
}

export function initializeActionModal() {
  /* edit text in modal with text from specific object form */
  $(document).on('show.bs.modal', '#action_modal', function(e) {
    $(this).find('.modal-content .modal-title').text($(e.relatedTarget).attr('data-title'));
    $(this).find('.modal-body p.warning_message').text($(e.relatedTarget).attr('data-message'));
    $(this).find('.modal-body span.object_type').text($(e.relatedTarget).attr('data-object-type'));
    $(this).find('.modal-body strong.object_name').text($(e.relatedTarget).attr('data-object-name'));
    $(this).find('.modal-body span.object_action').text($(e.relatedTarget).attr('data-object-action'));
    $(this).find('.modal-body input.confirm_object_name').attr('placeholder', $(e.relatedTarget).attr('data-object-type'));

    /* set data-form for modal to correct form */
    $('#modal_confirm_remove').data('form', $(e.relatedTarget).closest('form'));
  });

  /* enable the remove button if the input field matches the object name */
  $(document).on('keyup', '#action_modal input.confirm_object_name', function(e) {
    if ($(this).parent().siblings('p').children('strong.object_name').text() == $(this).val()) {
      $('#modal_confirm_remove').attr('disabled', false);

      if(e.keyCode == 13)
      {
         // simulate clicking the button if they press enter
         $('#modal_confirm_remove').click();
      }

    } else {
      $('#modal_confirm_remove').attr('disabled', true);
    }
  });

  $(document).on('hidden.bs.modal', '#action_modal', function () {
    $(this).find('input.confirm_object_name').val('');
    $('#modal_confirm_remove').attr('disabled', true);
  })

  /* submit deletion of specific object */
  $(document).on('click', '#modal_confirm_remove', function() {
    // all checked checkbox type inputs within a delete_vendor_patient_form class
    // collect ids
    var checked = $('.delete_vendor_patients_form input:checkbox:checked')
    if(checked.length>0){
      var ids = $.map(checked, function(val, i){
        return $(val).attr('id');
      });
      var input = $("<input>")
                 .attr("type", "hidden")
                 .attr("name", "patient_ids").val(ids);
      $(this).data('form').append(input);
    }
    $(this).data('form').submit();
  });
}

export function initializeAdmin() {
  var assignmentIndex = 1000;
  var  addAssignment = function(e){
    assignmentIndex++;
    e.preventDefault();
    var vendor = $("#vendor_select")[0].selectedOptions[0]
    var role =$("#role_select")[0].selectedOptions[0]
    //does the assignment already exist"
    //should this be done for a user that has a role other then user (atl,admin this means nothing as they alreay have those permissions)
    if( $("input[value='"+vendor.value+"'][name*='[vendor_id]']").length  == 0){
      var tr = $("<tr>")
      tr.append($("<td>"+role.text + "</td>"))
      tr.append($("<td>"+vendor.text + "</td>"))
      var buttonTd = $("<td>");
      tr.append(buttonTd);
      buttonTd.append($("<input type='hidden' name='assignments["+assignmentIndex+"][vendor_id]' value='"+vendor.value+"'/>"))
      buttonTd.append($("<input type='hidden' name='assignments["+assignmentIndex+"][role]' value='"+role.value+"'/>"))
      buttonTd.append($("<button onclick='$(this).parent().parent().remove()' > Remove </button>"))
      $('#assignments').append(tr);
    }
  }
  $("#addAssignment").click(addAssignment)

  $('.settings-tabs').tabs()
  $('.settings-tabs > ul > li').removeClass("ui-corner-top");

  var $customModeButtons = $("input[name='mode']");

  $customModeButtons.on('change', function() {
    if ($customModeButtons.filter(':checked').val() == "custom") {
      $('#settings-custom').show();
    } else {
      $('#settings-custom').hide();
    }
  });

  $customModeButtons.trigger('change');

  $('.activity-paginate').click(function (event) {
    Turbolinks.ProgressBar.start();
    Turbolinks.ProgressBar.advanceTo(25);
  });
}

export function updateBundleStatus() {
  function elementContainsText(selector, text) {
      return $(selector).text().indexOf(text) > -1;
  }

  if (elementContainsText('.tracker-status', 'queued') || elementContainsText('.tracker-status', 'working')) {
    $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'bundle_list'}});
  }
}

export function initializeChecklistTest() {
  // Enable changing measures
  $('#save_options').find('button').on('click', function (event) {
    event.preventDefault();
    $('.btn-danger').attr('disabled', false);
  });

  // For each criteria, lookup if its a negated code or vs, to set toggle lable
  var li = document.getElementsByClassName("data-criteria");
  for (var i = 0; i < li.length; i++) {
    lookupLabelFunction(i)
  }
  $(document).on('click', '#modify_record', function(event) {
    event.preventDefault();
    $('.hide-me').hide();
    $('.show-me').show();
  });

  $(document).on('click', 'button.modal-btn', function(event) {
    event.preventDefault();
    var currentTarget = event.currentTarget;
    var index_value = $(currentTarget).data("index-value");
    var attribute_value = $(currentTarget).data("attribute-value");
    var code_string = $(currentTarget).data("code-string");
    var input_box_type
    if (attribute_value == false){
      input_box_type = "code";
      document.getElementById("product_test_checked_criteria_attributes_" + index_value + "_" + input_box_type).value = code_string;
      $('#lookupModal' + index_value).modal('hide');
    }
    if (attribute_value == true){
      input_box_type ="attribute_code";
      document.getElementById("product_test_checked_criteria_attributes_" + index_value + "_" + input_box_type).value = code_string;
      $('#lookupModal-negation' + index_value).modal('hide') && $('#lookupModal-fieldvalues' + index_value).modal('hide') && $('#lookupModal-result' + index_value).modal('hide');
    }
  });
}

export function lookupFunction(index,is_att) {
  // Declare variables
  var input, filter, ul, li, a, i;
  input = document.getElementById("lookupFilter"+index+is_att);
  filter = input.value.toUpperCase();
  ul = document.getElementById("lookup_codes"+index+is_att);
  li = ul.getElementsByTagName('li');

  // Loop through all list items, and hide those who don't match the search query
  for (i = 0; i < li.length; i++) {
      a = li[i].getElementsByTagName("i")[0];
      if(a.innerHTML.toUpperCase().indexOf(filter) > -1){
          li[i].style.display = "";
      } else {
          li[i].style.display = "none";
      }
  }
}

export function initializeCollapsible() {
  var collapse_ready;
  collapse_ready = function() {
    $(document).on('click', '.collapsible', function(e) {
      this.classList.toggle("active");
      var content = this.nextElementSibling;
      if (content.style.display === "block") {
        content.style.display = "none";
      } else {
        content.style.display = "block";
      }
    });
  };
  $(document).ready(collapse_ready);
}

export function initializeInfiniteScroll() {
  viewMore = $('#view-more');

  // Call checkAndLoad now and when the page scrolls
  checkAndLoad();
  $(window).on('scroll', checkAndLoad);

  viewMore.find('a').unbind('click').click(function(e) {
    nextPage();
    return e.preventDefault();
  });
}

export function initializeRecord() {
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

export function initializeTestExecution() {
  // switch view to selected test execution
  $("#view_execution").click(function(event) {
    window.location.href = $("#select_execution").val();
  });

  $("#submit-upload").click(function(event) {
    event.preventDefault();
    $("#new_test_execution").submit();
  });
  initializeTestExecutionResults();
}
