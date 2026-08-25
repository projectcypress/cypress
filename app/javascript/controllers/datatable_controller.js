import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    searching: { type: Boolean, default: false },
    paging: { type: Boolean, default: false },
    stateSave: { type: Boolean, default: true },
    info: { type: Boolean, default: false },
    autoWidth: { type: Boolean, default: false },
    deferRender: { type: Boolean, default: true },
    order: Array,
    lengthMenu: Array,
    columnDefs: Array
  };

  connect() {
    this.$ = window.jQuery;
    if (!this.$?.fn || typeof this.$.fn.DataTable !== "function") return;

    this.handleShown = this.handleShown.bind(this);

    if (this.$.fn.dataTable.isDataTable(this.element)) {
      this.adjustTable();
    } else {
      const options = {
        searching: this.searchingValue,
        paging: this.pagingValue,
        stateSave: this.stateSaveValue,
        info: this.infoValue,
        autoWidth: this.autoWidthValue,
        deferRender: this.deferRenderValue
      };

      if (this.hasOrderValue) options.order = this.orderValue;
      if (this.hasLengthMenuValue) options.lengthMenu = this.lengthMenuValue;
      if (this.hasColumnDefsValue) options.columnDefs = this.columnDefsValue;

      this.$(this.element).DataTable(options);
      this.adjustTable();
    }

    document.addEventListener("shown.bs.tab", this.handleShown);
    this.$(document).on("tabsactivate", this.handleShown);
  }

  disconnect() {
    document.removeEventListener("shown.bs.tab", this.handleShown);

    if (this.$) {
      this.$(document).off("tabsactivate", this.handleShown);
    }
  }

  handleShown() {
    this.adjustTable();
  }

  adjustTable() {
    if (!this.$?.fn?.dataTable?.isDataTable(this.element)) return;

    setTimeout(() => {
      if (!document.body.contains(this.element)) return;
      this.$(this.element).DataTable().columns.adjust().draw(false);
    }, 0);
  }
}
