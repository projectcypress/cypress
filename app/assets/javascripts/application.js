/*global Turbolinks */

//= require turbolinks
//= require jquery2
//= require jquery_ujs
//= require jquery.remotipart
//= require parsley/parsley
//= require dragon_drop/dragon-drop
//= require dataTables/jquery.dataTables
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/tabs
//= require jquery-ui/widgets/accordion
//= require jquery-ui/widgets/button
//= require jquery-ui/widgets/dialog
//= require jquery-ui/widgets/menu
//= require jquery-ui/widgets/progressbar
//= require jquery-ui/widgets/slider
//= require jquery-ui/widgets/spinner
//= require jquery-ui/widgets/tooltip
//= require jquery-ui/widgets/datepicker
//= require assets_framework/assets.core
//= require assets_framework/breadcrumb
//= require jasny-bootstrap.min
//= require local-time
//= require_tree .
//= require popper
//= require bootstrap-sprockets

// will cover turbolinks changes (ajax already covered by rails ujs)
// this is necessary for CSRF tokens in changed form elements
// any statically changed form elements will require a separate token refresh call
$(document).on('page:load page:partial-load page:restore turbolinks:load', function () {
  $.rails.refreshCSRFTokens();
});

$(function() {
  Turbolinks.ProgressBar.enable();
  $('.breadcrumb').breadcrumb();

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
