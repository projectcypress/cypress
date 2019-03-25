/*global Turbolinks */

//= require turbolinks
//= require jquery2
//= require jquery_ujs
//= require jquery.remotipart
//= require parsley/parsley
//= require dataTables/jquery.dataTables
//= require jquery-ui/widgets/autocomplete
//= require jquery-ui/widgets/tabs
//= require bootstrap/transition
//= require bootstrap/modal
//= require bootstrap/alert
//= require bootstrap/tab
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require bootstrap/collapse
//= require bootstrap/dropdown
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
//= require jquery_nested_form
//= require jasny-bootstrap.min
//= require local-time
//= require_tree .

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
