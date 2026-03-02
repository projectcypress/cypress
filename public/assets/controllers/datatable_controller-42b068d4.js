import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";
import "datatables";

export default class extends Controller {
  connect() {
    $("measure_tests_table").DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    });
  }
}
