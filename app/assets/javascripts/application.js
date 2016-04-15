/*global Turbolinks */

//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require parsley/parsley
//= require dataTables/jquery.dataTables
//= require jquery-ui/autocomplete
//= require jquery-ui/tabs
//= require bootstrap/tab
//= require bootstrap/tooltip
//= require bootstrap/popover
//= require assets_framework/assets.core
//= require assets_framework/breadcrumb
//= require jquery_nested_form
//= require jasny-bootstrap.min
//= require_tree .

$(function() {
  Turbolinks.enableProgressBar();
  $('.breadcrumb').breadcrumb();
});
