import { Controller } from "@hotwired/stimulus";
import $ from "jquery";
import "datatables.net";

export default class extends Controller {
  connect() {
    $(this.element).DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    });
  }
}
