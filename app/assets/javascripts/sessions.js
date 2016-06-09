var placeSignInPanel = function() {
  if ($('.splash-title-container').length)  {
    var titleContainerRightPos = $('.splash-title-container').offset().left + $('.splash-title-container').width()
    var splashPanelRightPos = $('.splash-panel').offset().left + $('.splash-panel').width()
    var roomForSignInPanel = (splashPanelRightPos - titleContainerRightPos) > $('.sign-in-panel').width();
    if ($(".sign-in-panel").parent().is(".splash-panel") && !roomForSignInPanel) {
      $(".sign-in-panel").prependTo(".splash-info-panels-container");
      $(".sign-in-panel").css({"float":"none","margin":"auto","margin-bottom":"5px","display":"block","left":"0px","position":"relative"});
    } else if ($(".sign-in-panel").parent().is(".splash-info-panels-container") && roomForSignInPanel) {
      $(".sign-in-panel").appendTo(".splash-panel");
      $(".sign-in-panel").removeAttr('style');
    }
  }
};

$(window).resize(placeSignInPanel);
$(document).ready(placeSignInPanel);
$(document).on("page:change", placeSignInPanel);
