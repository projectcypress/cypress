// checklist_test_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._boundClick = this.onClick.bind(this)
    document.addEventListener("click", this._boundClick, true)

    this.initializeLookupLabels()
  }

  disconnect() {
    document.removeEventListener("click", this._boundClick, true)
  }

  // -----------------------------
  // Initializers
  // -----------------------------
  initializeLookupLabels() {
    const items = document.getElementsByClassName("data-criteria")
    for (let i = 0; i < items.length; i++) {
      this.lookupLabelFunction(i)
    }
  }

  // -----------------------------
  // Events (delegated)
  // -----------------------------
  onClick(event) {
    // Enable save options -> enable danger buttons
    const saveBtn = event.target.closest("#save_options button")
    if (saveBtn) {
      event.preventDefault()
      document.querySelectorAll(".btn-danger").forEach((el) => {
        el.disabled = false
        el.removeAttribute("disabled")
      })
      return
    }

    // Modify record: hide/show sections
    const modify = event.target.closest("#modify_record")
    if (modify) {
      event.preventDefault()
      document.querySelectorAll(".hide-me").forEach((el) => (el.style.display = "none"))
      document.querySelectorAll(".show-me").forEach((el) => (el.style.display = ""))
      return
    }

    // Modal selection button
    const modalBtn = event.target.closest("button.modal-btn")
    if (modalBtn) {
      event.preventDefault()

      const indexValue = modalBtn.dataset.indexValue
      const attributeValue = modalBtn.dataset.attributeValue
      const codeString = modalBtn.dataset.codeString || ""

      if (indexValue == null) return

      if (attributeValue === "false" || attributeValue === false) {
        const inputBoxType = "code"
        const input = document.getElementById(
          `product_test_checked_criteria_attributes_${indexValue}_${inputBoxType}`,
        )
        if (input) input.value = codeString

        this.hideModalById(`lookupModal${indexValue}`)
        return
      }

      if (attributeValue === "true" || attributeValue === true) {
        const inputBoxType = "attribute_code"
        const input = document.getElementById(
          `product_test_checked_criteria_attributes_${indexValue}_${inputBoxType}`,
        )
        if (input) input.value = codeString

        this.hideModalById(`lookupModal-negation${indexValue}`)
        this.hideModalById(`lookupModal-fieldvalues${indexValue}`)
        this.hideModalById(`lookupModal-result${indexValue}`)
      }
    }
  }

  // -----------------------------
  // Helpers (ported from your functions)
  // -----------------------------
  hideModalById(id) {
    const el = document.getElementById(id)
    if (!el) return
    if (!window.bootstrap?.Modal) return

    const modal = window.bootstrap.Modal.getInstance(el) || new window.bootstrap.Modal(el)
    modal.hide()
  }

  lookupLabelFunction(index) {
    const input = document.getElementById(`code${index}`)
    if (!input) return

    const checkbox = document.getElementById(
      `product_test_checked_criteria_attributes_${index}_negated_valueset`,
    )
    if (!checkbox) return

    const codeDiv = document.querySelector(`div#code${index}`)
    const vsDiv = document.querySelector(`div#vs${index}`)

    if (checkbox.checked) {
      if (codeDiv) codeDiv.style.display = "none"
      if (vsDiv) vsDiv.style.display = ""
    } else {
      if (vsDiv) vsDiv.style.display = "none"
      if (codeDiv) codeDiv.style.display = ""
    }
  }
}
