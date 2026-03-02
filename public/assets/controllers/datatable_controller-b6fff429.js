import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

export default class extends Controller {
  connect() {
    if (!$.fn.DataTable) return;
    if ($.fn.dataTable.isDataTable(this.element)) return;

    if ($(this.element).hasClass("measure_tests_table")) {
      $(this.element).DataTable({
        destroy: true,
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
      });
    } else if ($(this.element).hasClass("user_table")) {
      $(this.element).DataTable({
        destroy: true,
        searching: false,
        paging: true,
        lengthMenu: [
          [10, 25, 50, 100, -1],
          [10, 25, 50, 100, "All"],
        ],
        stateSave: true /* preserves order on reload */,
        info: false,
        columnDefs: [
          { orderable: true, className: "reorder", targets: [0, 1, 2] },
          { orderable: false, targets: "_all" },
        ],
      });
    } else if ($(this.element).hasClass("patient_table")) {
      $(this.element).DataTable({
        destroy: true,
        searching: false,
        paging: true,
        lengthMenu: [
          [10, 25, 50, 100, -1],
          [10, 25, 50, 100, "All"],
        ],
        stateSave: true /* preserves order on reload */,
        info: false,
      });
    }
  }
}
