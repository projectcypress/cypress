import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects data-controller="checklist-measure"
export default class extends Controller {
  connect() {
    $(".criteria-selector").change(function () {
      // find attribute in next table row
      var attributeSelector = $(this)
        .closest("tr")
        .next("tr")
        .find(".attribute-selector");
      var measure = $(this).closest(".card-group").attr("id");
      var criteria = $(this).children("option:selected").text();
      attributeSelector.empty(); // remove old options

      attr_hash[measure][criteria].forEach(function (attribute, index) {
        var option = $("<option></option>")
          .attr("value", attribute)
          .text(attribute);
        attributeSelector.append(option);
      });
    });
  }

  url() {
    // prefer reading from a data-url attribute to avoid embedding Ruby in JS
    return this.element.dataset.url;
  }
}
