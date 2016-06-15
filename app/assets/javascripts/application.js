/*global Turbolinks */

//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require parsley/parsley
//= require dataTables/jquery.dataTables
//= require jquery-ui/autocomplete
//= require jquery-ui/tabs
//= require bootstrap/transition
//= require bootstrap/modal
//= require bootstrap/alert
//= require bootstrap/tab
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require jquery-ui/accordion
//= require jquery-ui/button
//= require jquery-ui/dialog
//= require jquery-ui/menu
//= require jquery-ui/progressbar
//= require jquery-ui/slider
//= require jquery-ui/spinner
//= require jquery-ui/tooltip
//= require jquery-ui/datepicker
//= require assets_framework/assets.core
//= require assets_framework/breadcrumb
//= require jquery_nested_form
//= require jasny-bootstrap.min
//= require local_time
//= require_tree .

$(function() {
  Turbolinks.enableProgressBar();
  $('.breadcrumb').breadcrumb();
});
