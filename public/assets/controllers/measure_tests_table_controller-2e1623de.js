import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects to data-controller="measure-tests-table"
export default class extends Controller {
  connect() {
    $.ajax({
      url: this.url(),
      type: "GET",
      dataType: "script", // if you really need .js.erb responses
      data: {
        partial: "measure_tests_table",
        should_include_c1: this.includeC1(),
        html_id: this.html(),
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

  includeC1() {
    return this.element.dataset.includeC1;
  }

  html() {
    return this.element.dataset.html;
  }
}
