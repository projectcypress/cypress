document.addEventListener("DOMContentLoaded", () => {
  const commentsContainer = document.getElementById("pocs");
  const addCommentButton = document.getElementById("add-poc");

  let uniqueIndex = new Date().getTime();

  addCommentButton.addEventListener("click", () => {
    // Get the template for a new comment
    const newCommentTemplate = document.querySelector("#new-poc-template").innerHTML;

    const newFieldHtml = newCommentTemplate.replace(/new_record/g, uniqueIndex);

    // Insert the new comment fields into the container
    commentsContainer.insertAdjacentHTML("beforeend", newFieldHtml);

    uniqueIndex++;
  });

  commentsContainer.addEventListener("click", (event) => {
    if (event.target.classList.contains("remove-poc")) {
      const nestedFields = event.target.closest(".nested-fields");
      nestedFields.querySelector('input[name*="_destroy"]').value = "1";
      nestedFields.style.display = "none";
    }
  });
});