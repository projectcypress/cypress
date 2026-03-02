import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects data-controller="bulk-download"
export default class extends Controller {
  connect() {
    $.ajax({
      url: this.url(),
      type: "GET",
      dataType: "script", // if you really need .js.erb responses
      data: { partial: "bulk_download" },
      complete() {
        document.dispatchEvent(new CustomEvent("cypress:init"));
      },
    });
  }

  url() {
    // prefer reading from a data-url attribute to avoid embedding Ruby in JS
    return this.element.dataset.url;
  }
}
