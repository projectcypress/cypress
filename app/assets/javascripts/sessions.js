var placeSignInPanel = function() {
  if ($(".splash-title-container").length)  {
    var titleContainerRightPos = $(".splash-title-container").offset().left + $(".splash-title-container").width()
    var splashPanelRightPos = $(".splash-panel").offset().left + $(".splash-panel").width()
    var roomForSignInPanel = (splashPanelRightPos - titleContainerRightPos) > $(".sign-in-panel-container").width();
    if ($(".sign-in-panel-container").parent().is(".splash-panel") && !roomForSignInPanel) {
      $(".sign-in-panel-container").prependTo(".splash-info-panels-container");
      $(".sign-in-panel-container").toggleClass("sign-in-panel-container-moved");
    } else if ($(".sign-in-panel-container").parent().is(".splash-info-panels-container") && roomForSignInPanel) {
      $(".sign-in-panel-container").appendTo(".splash-panel");
      $(".sign-in-panel-container").toggleClass("sign-in-panel-container-moved");
    }
  }
};

$(window).resize(placeSignInPanel);
$(document).ready(placeSignInPanel);
$(document).on("page:change", placeSignInPanel);
