// product_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "cvuplus",
    "vendorPatients",
    "bundlePatients",
    "c1Test",
    "c2Test",
    "c3Test",
    "c4Test",
    "bundleOptions",
    "certificationOptions",
    "certificationEdition",
  ]

  connect() {
    this.syncFromCheckedRadio()
  }

  cvuplusChanged(event) {
    if (event.target.disabled) return
    this.applyState(event.target.value === "true")
  }

  syncFromCheckedRadio() {
    const checked = this.cvuplusTargets.find((el) => el.checked)
    if (!checked) return
    this.applyState(checked.value === "true")
  }

  applyState(cvuplusChecked) {
    const checked = this.cvuplusTargets.find((el) => el.checked)

    // Match prior behavior: only disable/enable inputs if the radio isn't disabled
    if (!checked || !checked.disabled) {
      this.setCheckboxDisabledNoUncheck(this.vendorPatientsTarget, !cvuplusChecked)
      this.setCheckboxDisabledNoUncheck(this.bundlePatientsTarget, !cvuplusChecked)

      this.setCheckboxDisabledNoUncheck(this.c1TestTarget, cvuplusChecked)
      this.setCheckboxDisabledNoUncheck(this.c2TestTarget, cvuplusChecked)
      this.setCheckboxDisabledNoUncheck(this.c3TestTarget, cvuplusChecked)
      this.setCheckboxDisabledNoUncheck(this.c4TestTarget, cvuplusChecked)
    }

    this.setElementHidden(this.bundleOptionsTarget, !cvuplusChecked)
    this.setElementHidden(this.certificationOptionsTarget, cvuplusChecked)
    this.setElementHidden(this.certificationEditionTarget, cvuplusChecked)
  }

  setCheckboxDisabledNoUncheck(inputEl, state) {
    const formCheck = inputEl.closest("div.form-check") || inputEl
    const nodes = [formCheck, ...formCheck.querySelectorAll("*")]

    nodes.forEach((node) => {
      node.classList.toggle("disabled", state)
      if (state) node.setAttribute("disabled", "disabled")
      else node.removeAttribute("disabled")
    })

    inputEl.disabled = state
  }

  setElementHidden(el, state) {
    el.classList.toggle("hidden", state)
    el.hidden = state
  }
}
