// action_modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "warningMessage",
    "objectType",
    "objectName",
    "objectAction",
    "confirmInput",
    "confirmButton",
  ]

  connect() {
    this._relatedForm = null

    this._boundOnShow = this.onShow.bind(this)
    this._boundOnHidden = this.onHidden.bind(this)
    this._boundOnKeyup = this.onKeyup.bind(this)
    this._boundOnConfirm = this.onConfirm.bind(this)
    this._boundBeforeCache = this.beforeCache.bind(this)

    this.element.addEventListener("show.bs.modal", this._boundOnShow)
    this.element.addEventListener("hidden.bs.modal", this._boundOnHidden)

    if (this.hasConfirmInputTarget) {
      this.confirmInputTarget.addEventListener("keyup", this._boundOnKeyup)
    }
    if (this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.addEventListener("click", this._boundOnConfirm)
    }

    document.addEventListener("turbo:before-cache", this._boundBeforeCache)
  }

  disconnect() {
    this.element.removeEventListener("show.bs.modal", this._boundOnShow)
    this.element.removeEventListener("hidden.bs.modal", this._boundOnHidden)

    if (this.hasConfirmInputTarget) {
      this.confirmInputTarget.removeEventListener("keyup", this._boundOnKeyup)
    }
    if (this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.removeEventListener("click", this._boundOnConfirm)
    }

    document.removeEventListener("turbo:before-cache", this._boundBeforeCache)
  }

  get bootstrapModal() {
    if (!window.bootstrap?.Modal) return null
    return window.bootstrap.Modal.getInstance(this.element) || new window.bootstrap.Modal(this.element)
  }

  hideModal() {
    this.bootstrapModal?.hide()

    // extra cleanup (helps with Turbo + Bootstrap)
    document.body.classList.remove("modal-open")
    document.querySelectorAll(".modal-backdrop").forEach((b) => b.remove())
  }

  beforeCache() {
    // ensure Turbo doesn't cache an "open" modal
    this.hideModal()
  }

  syncCsrfToken(form) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (!token || !form) return
    const hidden = form.querySelector('input[name="authenticity_token"]')
    if (hidden) hidden.value = token
  }

  onShow(event) {
    const trigger = event.relatedTarget
    if (!trigger) return

    const get = (name) => trigger.getAttribute(name) || ""

    if (this.hasTitleTarget) this.titleTarget.textContent = get("data-title")
    if (this.hasWarningMessageTarget) this.warningMessageTarget.textContent = get("data-message")
    if (this.hasObjectTypeTarget) this.objectTypeTarget.textContent = get("data-object-type")
    if (this.hasObjectNameTarget) this.objectNameTarget.textContent = get("data-object-name")
    if (this.hasObjectActionTarget) this.objectActionTarget.textContent = get("data-object-action")
    if (this.hasConfirmInputTarget) this.confirmInputTarget.placeholder = get("data-object-type")

    this._relatedForm = trigger.closest("form")
  }

  onKeyup(event) {
    const expected = this.hasObjectNameTarget ? this.objectNameTarget.textContent : ""
    const matches = expected === this.confirmInputTarget.value

    if (this.hasConfirmButtonTarget) this.confirmButtonTarget.disabled = !matches
    if (matches && event.keyCode === 13 && this.hasConfirmButtonTarget) {
      this.confirmButtonTarget.click()
    }
  }

  onHidden() {
    if (this.hasConfirmInputTarget) this.confirmInputTarget.value = ""
    if (this.hasConfirmButtonTarget) this.confirmButtonTarget.disabled = true
    this._relatedForm = null
  }

  onConfirm(event) {
    event.preventDefault()
    if (!this._relatedForm) return

    const checked = Array.from(
      document.querySelectorAll(".delete_vendor_patients_form input[type='checkbox']:checked"),
    )

    this._relatedForm.querySelector('input[name="patient_ids"]')?.remove()

    if (checked.length > 0) {
      const ids = checked.map((el) => el.getAttribute("id")).filter(Boolean)
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "patient_ids"
      input.value = ids.join(",")
      this._relatedForm.appendChild(input)
    }

    this.syncCsrfToken(this._relatedForm)

    // Hide modal BEFORE submitting/navigating
    this.hideModal()

    if (this._relatedForm.requestSubmit) this._relatedForm.requestSubmit()
    else this._relatedForm.submit()
  }
}
