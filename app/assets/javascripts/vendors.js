document.addEventListener("DOMContentLoaded", function() {
  var commentsContainer = document.getElementById("pocs");
  var addCommentButton = document.getElementById("add-poc");

  let uniqueIndex = new Date().getTime();

  addCommentButton.addEventListener("click", () => {
    // Get the template for a new comment
    var newCommentTemplate = document.querySelector("#new-poc-template").innerHTML;

    var newFieldHtml = newCommentTemplate.replace(/new_record/g, uniqueIndex);

    // Insert the new comment fields into the container
    commentsContainer.insertAdjacentHTML("beforeend", newFieldHtml);

    uniqueIndex++;
  });

  commentsContainer.addEventListener("click", (event) => {
    if (event.target.classList.contains("remove-poc")) {
      var nestedFields = event.target.closest(".nested-fields");
      nestedFields.querySelector('input[name*="_destroy"]').value = "1";
      nestedFields.style.display = "none";
    }
  });
});