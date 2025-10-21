import { Controller } from "@hotwired/stimulus";

// Connects data-controller="measure-search"
export default class extends Controller {
  static targets = ["input", "allRecordsTemplate"];
  static values = {
    // JSON array for jQueryUI autocomplete source
    source: String,
    allRecordsHtml: String,
  };

  connect() {
    this.initializeAutocomplete();
    this.bindKeyup();
  }

  disconnect() {
    try {
      $(this.inputTarget).autocomplete("destroy");
    } catch (_) {
      // ignore (autocomplete may not be initialized)
    }
  }

  initializeAutocomplete() {
    const $ = window.jQuery;
    let source = [];
    try {
      source = JSON.parse(this.sourceValue || "[]");
    } catch (e) {
      console.error("Bad source JSON", this.sourceValue, e);
    }

    $( "#search_measures" ).autocomplete({
      delay: 500,
      source: source,
      select: (event, data) => {
        $.get(data.item.value);
        event.preventDefault();
      },
      focus: (event) => event.preventDefault
    });
  }

  bindKeyup() {
    $(this.inputTarget).on("keyup.measureSearch", () => {
      if (!$(this.inputTarget).val()) {
        $("#records_list").html(this.allRecordsTemplateTarget.innerHTML);
      }
    });
  }
}
