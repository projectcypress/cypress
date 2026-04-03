// product_table_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.$ = window.jQuery
    if (!this.$) return

    this.initializeTabs()
    this.initializeDataTables()

    // delegated handler for dynamically-added upload fields
    this._boundMultiUploadChange = this.onMultiUploadChange.bind(this)
    document.addEventListener("change", this._boundMultiUploadChange, true)
  }

  disconnect() {
    if (this._boundMultiUploadChange) {
      document.removeEventListener("change", this._boundMultiUploadChange, true)
    }
  }

  initializeTabs() {
    if (!this.$.fn || typeof this.$.fn.tabs !== "function") return

    this.$(".product-test-tabs").each((_i, el) => {
      const $el = this.$(el)
      // avoid double-init
      if (!$el.hasClass("ui-tabs")) $el.tabs()
      $el.find("> ul > li").removeClass("ui-corner-top")
    })
  }

  initializeDataTables() {
    if (!this.$.fn || typeof this.$.fn.DataTable !== "function") return
    const isDT = (elOrSelector) => this.$.fn.dataTable.isDataTable(elOrSelector)

    // user_tests_table
    this.$(".user_tests_table").each((_i, el) => {
      if (isDT(el)) return
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
        order: [[4, "desc"]],
      })
    })

    // vendor-table
    this.$(".vendor-table").each((_i, el) => {
      if (isDT(el)) return
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
      })
    })

    // vendor-table-favorite
    this.$(".vendor-table-favorite").each((_i, el) => {
      if (isDT(el)) return
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
      })
    })

    // filtering_test_status_display (special case)
    if (
      this.$("#display_filtering_test_status_display_body").length &&
      !isDT("#filtering_test_status_display")
    ) {
      this.$("#filtering_test_status_display").DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
      })
    }

    // user_table
    this.$(".user_table").DataTable({
      destroy: true,
      searching: false,
      paging: true,
      lengthMenu: [
        [10, 25, 50, 100, -1],
        [10, 25, 50, 100, "All"],
      ],
      stateSave: true,
      info: false,
      columnDefs: [
        { orderable: true, className: "reorder", targets: [0, 1, 2] },
        { orderable: false, targets: "_all" },
      ],
    })

    // patient_table
    this.$(".patient_table").DataTable({
      destroy: true,
      searching: false,
      paging: true,
      lengthMenu: [
        [10, 25, 50, 100, -1],
        [10, 25, 50, 100, "All"],
      ],
      stateSave: true,
      info: false,
    })

    // measure_tests_table
    this.$(".measure_tests_table").DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    })
  }

  onMultiUploadChange(ev) {
    const input = ev.target
    if (!(input instanceof Element)) return
    if (!input.matches(".multi-upload-field")) return

    // mimic: $(this).parent().siblings(".multi-upload-submit").click();
    const parent = input.parentElement
    const submit = parent && parent.parentElement
      ? parent.parentElement.querySelector(":scope > .multi-upload-submit")
      : null

    if (submit instanceof HTMLElement) submit.click()
  }
}
