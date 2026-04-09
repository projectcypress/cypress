// product_table_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.$ = window.jQuery
    if (!this.$) return

    this.initializeTabs()
    this.initializeDataTables()

    this._boundMultiUploadChange = this.onMultiUploadChange.bind(this)
    document.addEventListener("change", this._boundMultiUploadChange, true)

    this._boundBeforeStreamRender = this.onBeforeStreamRender.bind(this)
    document.addEventListener("turbo:before-stream-render", this._boundBeforeStreamRender)
  }

  disconnect() {
    if (this._boundMultiUploadChange) {
      document.removeEventListener("change", this._boundMultiUploadChange, true)
    }

    if (this._boundBeforeStreamRender) {
      document.removeEventListener("turbo:before-stream-render", this._boundBeforeStreamRender)
    }
  }

  initializeTabs() {
    if (!this.$.fn || typeof this.$.fn.tabs !== "function") return

    this.$(".product-test-tabs").each((_i, el) => {
      const $el = this.$(el)
      if (!$el.hasClass("ui-tabs")) $el.tabs()
      $el.find("> ul > li").removeClass("ui-corner-top")
    })
  }

  initializeDataTables() {
    if (!this.$.fn || typeof this.$.fn.DataTable !== "function") return
    const isDT = (elOrSelector) => this.$.fn.dataTable.isDataTable(elOrSelector)

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

    this.$(".vendor-table").each((_i, el) => {
      if (isDT(el)) return
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
      })
    })

    this.$(".vendor-table-favorite").each((_i, el) => {
      if (isDT(el)) return
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
      })
    })

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

    this.$(".measure_tests_table").DataTable({
      destroy: true,
      searching: false,
      paging: false,
      stateSave: true,
      info: false,
    })
  }

  onBeforeStreamRender(event) {
    const streamElement = event.target
    const action = streamElement.getAttribute("action")
    const targetId = streamElement.getAttribute("target")

    if (action !== "update") return
    if (!targetId || !targetId.startsWith("measure-tests-table-row-wrapper-")) return

    const originalRender = event.detail.render

    event.detail.render = (stream) => {
      const row = document.getElementById(targetId)
      const table = row?.closest("table.measure_tests_table")
      let hadDataTable = false

      if (table && this.$.fn.dataTable.isDataTable(table)) {
        this.$(table).DataTable().destroy()
        hadDataTable = true
      }

      originalRender(stream)

      requestAnimationFrame(() => {
        if (hadDataTable && table) {
          this.$(table).DataTable({
            destroy: true,
            searching: false,
            paging: false,
            stateSave: true,
            info: false,
          })
        }
      })
    }
  }

  onMultiUploadChange(ev) {
    const input = ev.target
    if (!(input instanceof Element)) return
    if (!input.matches(".multi-upload-field")) return

    const parent = input.parentElement
    const submit = parent && parent.parentElement
      ? parent.parentElement.querySelector(":scope > .multi-upload-submit")
      : null

    if (submit instanceof HTMLElement) submit.click()
  }
}
