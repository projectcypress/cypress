var collapse_ready;
collapse_ready = function() {
  $(document).on('click', '.collapsible', function(e) {
    this.classList.toggle("active");
    var content = this.nextElementSibling;
    if (content.style.display === "block") {
      content.style.display = "none";
    } else {
      content.style.display = "block";
    }
  });
};
$(document).ready(collapse_ready);
// $(document).on('page:load page:restore page:partial-load', collapse_ready);
