
var ready;
ready = function() {
  $("#submit-upload").click(function(event) {
    event.preventDefault();
    $("#new_test_execution").submit();
  });

  /* enable each error popover */
  $('.error-popup-btn').popover();

  /* change 'view' and 'hide' text for popover buttons */
  $('.error-popup-btn').on('show.bs.popover', function () {
    this.children[0].innerText = this.children[0].innerText.replace('view', 'hide');
  });
  $('.error-popup-btn').on('hide.bs.popover', function () {
    this.children[0].innerText = this.children[0].innerText.replace('hide', 'view');
  });

  /* hide all error popovers when switching between error tabs */
  $('a.tab').on('click', function () {
    $('button.error-popup-btn').popover('hide');
  });

  /* link subnav with the execution_error_link s */
  var navigation =  $("#xml_frame .xml-nav").navigator({targets: "a.execution_error_link", action: show_error_popup_and_jump});
  $("#xml_frame").fixedHeader();

  /* used to set index on navigation bar when user clicks a execution_error_link and not a navbar button */
  $("#display_execution_results").on('click', 'a.execution_error_link', function(event) {
    href = $(this).attr('href');
    show_error_popup_and_jump(href);
    navigation.data('navigator').setIndex(href);
    return false;
  });

  function show_error_popup_and_jump(href) {
    if ($(href)) {
      $('button.error-popup-btn').popover('hide'); /* hide all error popovers before showing the new one */

      var scroll_time = 300;      /* (milisec) time it takes to scroll from one error popover to another */
      var highlight_time = 2000;  /* (milisec) time highlight lasts for individual error in error popover */
      var height_buffer = 20;     /* number of pixels between the xml_nav_bar and the error after done scrolling */

      var height_of_xmlnav_div = $('.xml-nav').outerHeight();
      var height_of_error_div = $(href).siblings('.error').outerHeight();
      var pixels_down_page = height_of_xmlnav_div + height_buffer + height_of_error_div; /* number of pixels down the page the error will apear after scrolling */

      /* scroll to error popover */
      $('html,body').animate({ scrollTop: $(href).offset().top - pixels_down_page }, { duration: scroll_time, easing: 'swing'}).promise().done(function() {
        $('button.' + href.replace('#', '')).popover('toggle');           /* show popover for button with matching error id class */
        $('li.' + href.replace('#', '')).effect( "highlight", {}, 2000 ); /* temporarily highlight the error if there are a list of errors in the popover */
      });
    }
  }
}

$(document).ready(ready);
$(document).on('page:load', ready);
