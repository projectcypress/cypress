import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

export default class extends Controller {
  async connect() {
    // Ensure DataTables binds to THIS jQuery instance
    window.$ = window.jQuery = $;

    // IMPORTANT: dynamic import so it runs AFTER the globals above
    await import("datatables");

    $(this.element).DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    });
  }
}
