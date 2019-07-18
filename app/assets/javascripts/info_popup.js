// When the user clicks on div, open the popup
function popup(id) {
  var popup_element = document.getElementById(id);
  if(popup_element !== null){
    popup_element.classList.toggle("show");
  }
}

$(document).ready(popup);
$(document).on('page:load', popup);
