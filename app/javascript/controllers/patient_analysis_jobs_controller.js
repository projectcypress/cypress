import { Controller } from "@hotwired/stimulus";
import $ from "jquery2";

// Connects data-controller="patient-analysis-jobs"
export default class extends Controller {
  connect() {
    $(document).ready(function () {
      $.ajax({
        url: this.url(),
        type: "GET",
        dataType: "script",
        data: { partial: "patient_analysis_jobs" },
      });
    });
  }

  url() {
    // prefer reading from a data-url attribute to avoid embedding Ruby in JS
    return this.element.dataset.url;
  }
}
