var placeSignInPanel = function() {
  if ($(".splash-title-container").length)  {
    var signInLeft = $(".sign-in-panel-container").offset().left
    var titleWidth = $(".splash-title-container").width()
    var roomForSignInPanel = signInLeft >= titleWidth;
    if ($(".sign-in-panel-container").parent().is(".splash-panel") && !roomForSignInPanel) {
      $(".sign-in-panel-container").addClass("sign-in-panel-container-moved");
    } else if ($(".sign-in-panel-container").parent().is(".splash-panel") && roomForSignInPanel) {
      $(".sign-in-panel-container").removeClass("sign-in-panel-container-moved");
    }
  }
};

$(window).resize(placeSignInPanel);
$(document).ready(placeSignInPanel);
$(document).on("page:change", placeSignInPanel);
