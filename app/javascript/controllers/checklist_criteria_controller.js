import { Controller } from "@hotwired/stimulus";

// Connects data-controller="checklist-criteria"
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

    const cardGroup = criteriaSelect.closest(".card-group");
    const measure = cardGroup?.getAttribute("id");
    if (!measure) return;

    const criteriaText = criteriaSelect.selectedOptions?.[0]?.textContent;
    if (!criteriaText) return;

    attributeSelector.innerHTML = "";

    const attributes = this.attrHashValue?.[measure]?.[criteriaText] || [];

    attributes.forEach((attribute) => {
      const option = document.createElement("option");
      option.value = attribute;
      option.textContent = attribute;
      attributeSelector.appendChild(option);
    });
  }
}
