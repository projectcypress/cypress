/*eslint max-statements: ["error", 15]*/
var assignmentsReady = function(){
  var assignmentIndex = 1000;
  var  addAssignment = function(e){
    assignmentIndex++;
    e.preventDefault();
    var vendor = $("#vendor_select")[0].selectedOptions[0]
    var role =$("#role_select")[0].selectedOptions[0]
    //does the assignment already exist"
    //should this be done for a user that has a role other then user (atl,admin this means nothing as they alreay have those permissions)
    if( $("input[value='"+vendor.value+"'][name*='[vendor_id]']").length  == 0){
      var tr = $("<tr>")
      tr.append($("<td>"+role.text + "</td>"))
      tr.append($("<td>"+vendor.text + "</td>"))
      var buttonTd = $("<td>");
      tr.append(buttonTd);
      buttonTd.append($("<input type='hidden' name='assignments["+assignmentIndex+"][vendor_id]' value='"+vendor.value+"'/>"))
      buttonTd.append($("<input type='hidden' name='assignments["+assignmentIndex+"][role]' value='"+role.value+"'/>"))
      buttonTd.append($("<button onclick='$(this).parent().parent().remove()' > Remove </button>"))
      $('#assignments').append(tr);
    }
  }
  $("#addAssignment").click(addAssignment)

}

$(document).ready(assignmentsReady)

// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var ready;
ready = function() {
  $('.settings-tabs').tabs();

  var $customModeButtons = $('[name="[mode]"]');

  $customModeButtons.on('change', function() {
    if ($customModeButtons.filter(':checked').val() == "custom") {
      $('#settings-custom').show();
    } else {
      $('#settings-custom').hide();
    }
  });

  $customModeButtons.trigger('change');
};

$(document).ready(ready);
$(document).on('page:load', ready);
