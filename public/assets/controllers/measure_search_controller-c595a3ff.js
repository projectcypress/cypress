import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";
import "jquery-ui";

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
    const $input = $(this.inputTarget);

    let source = [];
    try {
      source = JSON.parse(this.sourceValue || "[]");
    } catch (e) {
      console.error("Bad source JSON", this.sourceValue, e);
    }

    $input.autocomplete({
      delay: 500,
      source: this.sourceValue,
      select: (event, data) => {
        $.get(data.item.value);
        event.preventDefault();
      },
      focus: (event) => event.preventDefault,
    });

    const ac = $input.data("ui-autocomplete");
    if (!ac) return;

    ac._renderItem = function (ul, item) {
      return $('<li class="list-group-item">').append(item.label).appendTo(ul);
    };

    ac._renderMenu = function (ul, items) {
      const that = this;
      $.each(items, function (_index, item) {
        this._renderItemData(ul, item);
      });
      $(ul).removeClass("ui-widget ui-widget-content").addClass("list-group");
    };
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
