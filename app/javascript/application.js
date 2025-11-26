/*global Turbolinks */

// require turbolinks
// require jquery2
// require jquery_ujs
// require jquery.remotipart
// require parsley/parsley
// require dragon_drop/dragon-drop
// require dataTables/jquery.dataTables
// require jquery-ui/widgets/autocomplete
// require jquery-ui/widgets/tabs
// require jquery-ui/widgets/accordion
// require jquery-ui/widgets/button
// require jquery-ui/widgets/dialog
// require jquery-ui/widgets/menu
// require jquery-ui/widgets/progressbar
// require jquery-ui/widgets/slider
// require jquery-ui/widgets/spinner
// require jquery-ui/widgets/tooltip
// require jquery-ui/widgets/datepicker
// require assets_framework/assets.core
// require assets_framework/breadcrumb
// require jasny-bootstrap.min
// require local-time
// require_tree .
// require popper

// import "turbolinks";
// import "popper";
// import "bootstrap";
// import "jasny-bootstrap";
// import "datatables.net";
// import "datatables.net-dt/css/jquery.dataTables.css";
// will cover turbolinks changes (ajax already covered by rails ujs)
// this is necessary for CSRF tokens in changed form elements
// any statically changed form elements will require a separate token refresh call


import $ from "jquery2";
//import jquery from "jquery2";
//import "parsley";
import * as cypress from "cypress";
import Turbolinks from "turbolinks";
import * as bootstrap from 'bootstrap';
import "datatables"
// import "jquery-ui/widgets/autocomplete"
import "jquery-ui"
// import "jquery-ui/widgets/accordion"
// import "jquery-ui/widgets/button"
// import "jquery-ui/widgets/dialog"
// import "jquery-ui/widgets/menu"
// import "jquery-ui/widgets/progressbar"
// import "jquery-ui/widgets/slider"
// import "jquery-ui/widgets/spinner"
// import "jquery-ui/widgets/tooltip"
// import "jquery-ui/widgets/datepicker"

//window.$ = jquery;
//window.jQuery = jquery;

$(document).on('page:load page:partial-load page:restore turbolinks:load', function () {
  $.rails.refreshCSRFTokens();
});

$(document).on('page:change', cypress.updateBundleStatus());

$(function() {
  cypress.initializeJqueryCvuRadio();
  cypress.initializeProductTable();
  cypress.reticulateSplines();
  cypress.initializeMeasureSelection();
  cypress.initializeActionModal();
  cypress.initializeAdmin();
  cypress.initializeChecklistTest();

  //$('.breadcrumb').breadcrumb();

  $(document).on('ajaxComplete',function(e){
    if(e.delegateTarget.activeElement.tagName.toLowerCase() == 'button') {
      $(e.delegateTarget.activeElement).blur();
    }
  });

  $(document).on('submit',function(e){
    window.setTimeout(function(){
      $(e.delegateTarget.activeElement).blur();
    }, 1500);
  });
});

document.addEventListener("DOMContentLoaded", function() {
  var commentsContainer = document.getElementById("pocs");
  var addCommentButton = document.getElementById("add-poc");
  var uniqueIndex = new Date().getTime();

  addCommentButton.addEventListener("click", function() {
    // Get the template for a new comment
    var newCommentTemplate = document.querySelector("#new-poc-template").innerHTML;

    var newFieldHtml = newCommentTemplate.replace(/new_record/g, uniqueIndex);

    // Insert the new comment fields into the container
    commentsContainer.insertAdjacentHTML("beforeend", newFieldHtml);

    uniqueIndex++;
  });

  commentsContainer.addEventListener("click", function(event) {
    if (event.target.classList.contains("remove-poc")) {
      var nestedFields = event.target.closest(".nested-fields");
      nestedFields.querySelector('input[name*="_destroy"]').value = "1";
      nestedFields.style.display = "none";
    }
  });
});
