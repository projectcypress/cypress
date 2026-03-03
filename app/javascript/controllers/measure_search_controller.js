import { Controller } from "@hotwired/stimulus";

// Connects data-controller="measure-search"
export default class extends Controller {
  static targets = ["input"];
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
    } catch (_) {}
  }

  initializeAutocomplete() {
    const $ = window.jQuery;
    let source = [];
    try {
      source = JSON.parse(this.sourceValue || "[]");
    } catch (e) {
      console.error("Bad source JSON", this.sourceValue, e);
    }
    var availableTags = [{"label":"CMS349v7: HIV Screening","value":"/bundles/66797c1bdfe4bd02748db95e/records/by_measure?measure_id=2C928083-8907-CE68-0189-0DA36CC00327\u0026pop_set_key=PopulationSet_1"}];
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
        $("#records_list").html(this.allRecordsHtmlValue);

        if ($.rails?.refreshCSRFTokens) $.rails.refreshCSRFTokens();
      }
    });
  }
}
