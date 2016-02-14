var ready;
ready = function() {

  /* hide tab content when tab is clicked again */
  $('a[data-toggle=tab]').click(function() {
    if ($(this).parent().hasClass('active')) {
      $($(this).attr('href')).toggleClass('active');
      /* toggle caret */
      $(get_caret_class($(this))).toggleClass('hide');
    }
  });

  /* display caret-up when tab content is displayed */
  $('a[data-toggle="tab"]').on('shown.bs.tab', function(e) {
    $(get_caret_class(e.target)).removeClass('hide');
  });

  /* hide caret-up when tab content is displayed */
  $('a[data-toggle="tab"]').on('hidden.bs.tab', function(e) {
    $(get_caret_class(e.target)).addClass('hide');
  });

  /* when close button for certification specifics popup is clicked: close popup and hide caret */
  $('.close-certification-specifics').click(function() {
    $($(this).attr('href')).toggleClass('active');
    $(get_caret_class($(this))).addClass('hide');
  });

  function get_caret_class(tab_element) { return '.' + $($(tab_element).attr('href')).attr('id') }
};

$(document).ready(ready);
$(document).on('page:load', ready);