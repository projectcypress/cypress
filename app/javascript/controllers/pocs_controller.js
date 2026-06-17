import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "template"];
  static values = { index: Number };

  connect() {
    if (!this.hasIndexValue) this.indexValue = Date.now();
  }

  add(event) {
    event.preventDefault();

    const html = this.templateTarget.innerHTML.replace(/new_record/g, this.indexValue);
    this.containerTarget.insertAdjacentHTML("beforeend", html);

    this.indexValue += 1;
  }

  remove(event) {
    event.preventDefault();

    const nestedFields = event.target.closest(".nested-fields");
    if (!nestedFields) return;

    const destroyInput = nestedFields.querySelector('input[name*="_destroy"]');
    if (destroyInput) destroyInput.value = "1";

    nestedFields.style.display = "none";
  }
}
