import { Controller } from "@hotwired/stimulus";

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
