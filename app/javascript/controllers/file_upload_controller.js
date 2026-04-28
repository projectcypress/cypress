// app/javascript/controllers/file_upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "filename", "pickLabel", "submit"]
  static values = { disabled: Boolean }

  connect() { this.refresh() }

  pick(event) {
    event.preventDefault()
    if (this.disabledValue) return
    this.inputTarget.click()
  }

  refresh() {
    const file = this.inputTarget.files?.[0]
    const hasFile = Boolean(file)

    this.filenameTarget.value = hasFile ? file.name : ""
    this.pickLabelTarget.textContent = hasFile ? "Change" : "Select file"

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = this.disabledValue || !hasFile
      this.submitTarget.classList.toggle("d-none", !hasFile)
    }
  }
}
