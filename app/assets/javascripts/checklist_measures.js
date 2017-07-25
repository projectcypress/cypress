/* exported lookupLabelFunction */
function lookupLabelFunction(index) {
// Declare variables
  var input, checkbox;
  input = document.getElementById("code"+index);
  if(input !== null){
    checkbox = document.getElementById("product_test_checked_criteria_attributes_"+index+"_negated_valueset");
    if(checkbox.checked == true){
      $("div#code"+index).hide()
      $("div#vs"+index).show()
    } else {
      $("div#vs"+index).hide()
      $("div#code"+index).show()
    }
  }
}

// these pieces should run only once, at page load
var ready_run_once;
ready_run_once = function() {

  // Enable changing measures
  $('#save_options').find('button.confirm').on('click', function (event) {
    event.preventDefault();
    $('.btn-danger').attr('disabled', false);
  });

  // For each criteria, lookup if its a negated code or vs, to set toggle lable
  var li = document.getElementsByClassName("data-criteria");
  for (var i = 0; i < li.length; i++) {
    lookupLabelFunction(i)
  }

};

$(document).ready(ready_run_once);
$(document).on('page:load', ready_run_once);

/* exported lookupFunction */
function lookupFunction(index,is_att) {
// Declare variables
var input, filter, ul, li, a, i;
input = document.getElementById("lookupFilter"+index+is_att);
filter = input.value.toUpperCase();
ul = document.getElementById("lookup_codes"+index+is_att);
li = ul.getElementsByTagName('li');

// Loop through all list items, and hide those who don't match the search query
for (i = 0; i < li.length; i++) {
    a = li[i].getElementsByTagName("i")[0];
    if(a.innerHTML.toUpperCase().indexOf(filter) > -1){
        li[i].style.display = "";
    } else {
        li[i].style.display = "none";
    }
}}

$(document).ready(function(){
        $('#modifyrecord').on('click', function(event) {
             event.preventDefault();
             $('.hide-me').hide();
             $('.show-me').show();

        });
    });


