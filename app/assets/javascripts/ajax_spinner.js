$(document).ready(function(){
  $('header h1').ajaxStart(function(){
    $(this).css("background", "url(/assets/busy.gif) top left no-repeat transparent");
  }).ajaxStop(function(){
    $(this).css("background", "url(/assets/cypress_logo.png) top left no-repeat transparent")
  });
})