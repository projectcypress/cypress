// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
  $('header h1').ajaxStart(function(){
    $(this).css("background", "url(/images/busy.gif) top left no-repeat transparent");
  }).ajaxStop(function(){
    $(this).css("background", "url(/images/cypress_logo.png) top left no-repeat transparent")
  });
})