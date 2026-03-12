import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects to data-controller="measure-tests-table-row"
export default class extends Controller {
  connect() {
    if (this.should_reload_measure_table_row()) {
      $.ajax({
        url: this.url(),
        type: "GET",
        dataType: "script", // if you really need .js.erb responses
        data: {
          partial: "measure_tests_table_row",
          task_id: this.task(),
          has_eh_tests: this.ehTests(),
          has_ep_tests: this.epTests(),
        },
        complete() {
          document.dispatchEvent(new CustomEvent("cypress:init"));
        },
      });
    }
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

  should_reload_measure_table_row() {
    return this.element.dataset.reload === "true";
  }
}
