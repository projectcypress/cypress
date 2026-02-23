import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const $ = window.$;

    $(this.element).DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    });
  }
}
