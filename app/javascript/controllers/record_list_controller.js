// record_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._boundClick = this.onClick.bind(this)
    this._boundChange = this.onChange.bind(this)

    document.addEventListener("click", this._boundClick, true)
    document.addEventListener("change", this._boundChange, true)

    // set initial state
    this.changePanel()
  }

  disconnect() {
    document.removeEventListener("click", this._boundClick, true)
    document.removeEventListener("change", this._boundChange, true)
  }

  /* eslint-disable max-statements */
  onClick(event) {
    // Bundle selection (click handler)
    const bundleInput = event.target.closest('input[name="bundle_id"]')
    if (bundleInput) {
      const bundleId = bundleInput.value
      bundleInput.checked = true

      let url = null
      const next = bundleInput.nextElementSibling
      if (next && next.classList.contains("bundle-checkbox")) {
        url = `/bundles/${bundleId}/records`
      } else if (next && next.classList.contains("vendor-checkbox")) {
        url = `?bundle_id=${bundleId}`
      }
      if (!url) return

      requestAnimationFrame(() => window.Turbo?.visit?.(url))
      return
    }

    // Select-all button
    const selectAllBtn = event.target.closest("#vendor-patient-select-all")
    if (selectAllBtn) {
      event.preventDefault()

      const icon = selectAllBtn.querySelector("i")
      const checkboxes = Array.from(
        document.querySelectorAll(".delete_vendor_patients_form input[type='checkbox']"),
      )

      const shouldCheck = (selectAllBtn.value || "unchecked") === "unchecked"
      checkboxes.forEach((cb) => (cb.checked = shouldCheck))

      if (icon) {
        icon.classList.toggle("fa-square", !shouldCheck)
        icon.classList.toggle("fa-check-square", shouldCheck)
      }

      selectAllBtn.title = shouldCheck ? "Unselect All" : "Select All"

      const text = document.querySelector("#vendor-patient-select-all-text")
      if (text) text.textContent = shouldCheck ? "Unselect All" : "Select All"

      selectAllBtn.value = shouldCheck ? "checked" : "unchecked"

      this.changePanel()
    }
  }
  /* eslint-enable max-statements */

  onChange(event) {
    const cb = event.target.closest(".delete_vendor_patients_form input[type='checkbox']")
    if (cb) this.changePanel()
  }

  // Stimulus version of changePanel (fixes the old toggleClass bug)
  changePanel() {
    const checkedCount = document.querySelectorAll(
      ".delete_vendor_patients_form input[type='checkbox']:checked",
    ).length

    const shouldShow = checkedCount > 0
    document.querySelectorAll(".checkbox-danger-panel").forEach((panel) => {
      panel.classList.toggle("d-none", !shouldShow)
    })
  }
}
