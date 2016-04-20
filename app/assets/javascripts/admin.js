var ready = function(){
  var assignmentIndex = 1000;
  var  addAssignment = function(e){
    assignmentIndex++;
    e.preventDefault();
    var vendor = $("#vendor_select")[0].selectedOptions[0]
    var role =$("#role_select")[0].selectedOptions[0]
    //does the assignment already exist"
    //should this be done for a user that has a role other then user (atl,admin this means nothing as they alreay have those permissions)
    if( $("input[value='"+vendor.value+"'][name*='[vendor_id]']").length  == 0){
      var div = $("<div>")
      div.append("Role: "+role.text + " Vendor: "+vendor.text);
      var roleIn = $("<input type='hidden' name='assignments["+assignmentIndex+"][vendor_id]' value='"+vendor.value+"'/>")
      var vendorIn = $("<input type='hidden' name='assignments["+assignmentIndex+"][role]' value='"+role.value+"'/>")
      var button = $("<button onclick='$(this).parent().remove()' > Remove </button>")
      div.append(roleIn)
      div.append(vendorIn)
      div.append(button)
      $('#assignments').append(div);
    }
  }
  $("#addAssignment").click(addAssignment)

}

$(document).ready(ready)
