import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects to data-controller="measure-tests-table-row"
export default class extends Controller {
  connect() {
    $.ajax({
      url: this.url(),
      type: "GET",
      dataType: "script", // if you really need .js.erb responses
      data: {
        partial: "measure_tests_table_row",
        task_id: this.task(),
        has_eh_tests: this.hasEhTests(),
        has_ep_tests: this.hasEpTests(),
      },
      complete() {
        document.dispatchEvent(new CustomEvent("cypress:init"));
      },
    });
  }

  url() {
    // Prefer reading from a data-url attribute to avoid embedding Ruby in JS
    return this.element.dataset.url;
  }

  task() {
    return this.element.dataset.task;
  }

  ehTests() {
    return this.element.dataset.ehTests;
  }

  epTests() {
    return this.element.dataset.epTests;
  }
}
