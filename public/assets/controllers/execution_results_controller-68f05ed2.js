import { Controller } from "@hotwired/stimulus"
import $ from "jquery2"

// Connects to data-controller="execution-results"
export default class extends Controller {
  connect() {
    $.ajax({
      url: this.url(),
      type: "GET",
      dataType: "script", // if you really need .js.erb responses
      data: { partial: "execution_results" },
      complete() {
        document.dispatchEvent(new CustomEvent("cypress:init"))
      }
    })
  }

  url() {
    // Prefer reading from a data-url attribute to avoid embedding Ruby in JS
    return this.element.dataset.url
  }
}
