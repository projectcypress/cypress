var ready;
ready = function() {

  $('.expand_pocs').click(function() {
    $(this).siblings('.pocs').children().not(':first').toggleClass('hide');
    $(this).html($(this).text() == '[+ More]' ? '[- Less]' : '[+ More]');
  });

};

$(document).ready(ready);
$(document).on('page:load', ready);