
var ready;
ready = function() {
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

$(document).on('page:change page:load', ready);

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
  $('.error-popup-btn').popover();

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
