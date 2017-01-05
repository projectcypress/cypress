// these pieces should run only once, at page load
var ready_run_once;
ready_run_once = function() {

  // Enable changing measures
  $('#save_options').find('button.confirm').on('click', function (event) {
    event.preventDefault();
    $('.btn-danger').attr('disabled', false);
  });


};

$(document).ready(ready_run_once);
$(document).on('page:load', ready_run_once);

var pop_up;
pop_up = function(){

	var pop_up = document.getElementById('code_lookup');
	pop_up.classList.toggle('show');
}

function lookupFunction() {
    // Declare variables
    var input, filter, ul, li, a, i;
    input = document.getElementById('lookupFilter');
    filter = input.value.toUpperCase();
    ul = document.getElementById("lookup_codes");
    li = ul.getElementsByTagName('li');

    // Loop through all list items, and hide those who don't match the search query
    for (i = 0; i < li.length; i++) {
        a = li[i].getElementsByTagName("a")[0];
        if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
            li[i].style.display = "";
        } else {
            li[i].style.display = "none";
        }
    }
}