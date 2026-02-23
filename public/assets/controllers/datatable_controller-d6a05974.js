import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

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
