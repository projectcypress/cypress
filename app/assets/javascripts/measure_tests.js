var ready;
ready = function() {
  // instatiate the tabs on the measure test page
  $('.measure-test-tabs').tabs();
}

$(document).on('page:load', ready);
