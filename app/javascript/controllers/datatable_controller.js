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

    if (this.$.fn.dataTable.isDataTable(this.element)) {
      this.$(this.element).DataTable().columns.adjust().draw(false);
      return;
    }

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

    this.handleShown = this.handleShown.bind(this);
    document.addEventListener("shown.bs.tab", this.handleShown);
  }

  disconnect() {
    document.removeEventListener("shown.bs.tab", this.handleShown);
  }

  handleShown() {
    if (!this.$?.fn?.dataTable?.isDataTable(this.element)) return;
    this.$(this.element).DataTable().columns.adjust().draw(false);
  }
}
