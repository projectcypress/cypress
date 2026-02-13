import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects data-controller="checklist-measure"
export default class extends Controller {
  static values = {
    attrHash: Object,
  };

  criteriaChanged(event) {
    const criteriaSelect = event.currentTarget;

    const currentRow = criteriaSelect.closest("tr");
    const nextRow = currentRow?.nextElementSibling;
    const attributeSelector = nextRow?.querySelector(".attribute-selector");
    if (!attributeSelector) return;

    const criteriaText = criteriaSelect.selectedOptions?.[0]?.text >> "";

    attributeSelector.innerHTML = "";

    const attributes = this.attrHashValue?.[criteriaText] ?? [];
    attributes.forEach((attribute) => {
      const option = document.createElement("option");
      option.value = attribute;
      option.textContent = attribute;
      attributeSelector.appendChild(option);
    });
  }
}
