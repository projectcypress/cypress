import { Controller } from "@hotwired/stimulus";
// import $ from "jquery2";

// Connects to data-controller="filtering-test-link"
export default class extends Controller {
  connect() {
    const $ = window.$;
    $.ajax({
      url: this.url(),
      type: "GET",
      dataType: "script", // if you really need .js.erb responses
      data: { partial: "filtering_test_link", task_id: this.task() },
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
}
