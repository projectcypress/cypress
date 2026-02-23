import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

export default class extends Controller {
  connect() {
    if (!$.fn.DataTable) return;
    if ($.fn.dataTable.isDataTable(this.element)) return;
    $(this.element).DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    });
  }
}
