// admin_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    assignmentIndex: { type: Number, default: 1000 },
  }

  connect() {
    this.$ = window.jQuery

    this._boundAddAssignment = this.addAssignment.bind(this)
    this._boundModeChange = this.onModeChange.bind(this)
    this._boundActivityPaginate = this.onActivityPaginateClick.bind(this)

    const addBtn = document.querySelector("#addAssignment")
    if (addBtn) addBtn.addEventListener("click", this._boundAddAssignment)

    document
      .querySelectorAll("input[name='mode']")
      .forEach((el) => el.addEventListener("change", this._boundModeChange))

    document
      .querySelectorAll(".activity-paginate")
      .forEach((el) => el.addEventListener("click", this._boundActivityPaginate))

    this.initializeTabs()
    this.onModeChange()
  }

  disconnect() {
    const addBtn = document.querySelector("#addAssignment")
    if (addBtn) addBtn.removeEventListener("click", this._boundAddAssignment)

    document
      .querySelectorAll("input[name='mode']")
      .forEach((el) => el.removeEventListener("change", this._boundModeChange))

    document
      .querySelectorAll(".activity-paginate")
      .forEach((el) => el.removeEventListener("click", this._boundActivityPaginate))
  }

  initializeTabs() {
    if (!this.$ || !this.$.fn || typeof this.$.fn.tabs !== "function") return
    this.$(".settings-tabs").tabs()
    this.$(".settings-tabs > ul > li").removeClass("ui-corner-top")
  }

  addAssignment(e) {
    e.preventDefault()
    this.assignmentIndexValue += 1

    const vendorSelect = document.querySelector("#vendor_select")
    const roleSelect = document.querySelector("#role_select")
    const assignments = document.querySelector("#assignments")
    if (!vendorSelect || !roleSelect || !assignments) return

    const vendor = vendorSelect.selectedOptions[0]
    const role = roleSelect.selectedOptions[0]
    if (!vendor || !role) return

    // prevent duplicates: does a hidden vendor_id already exist for this vendor?
    const existing = document.querySelectorAll(
      `input[name*='[vendor_id]'][value="${CSS.escape(vendor.value)}"]`,
    )
    if (existing.length > 0) return

    const tr = document.createElement("tr")

    const roleTd = document.createElement("td")
    roleTd.textContent = role.text
    tr.appendChild(roleTd)

    const vendorTd = document.createElement("td")
    vendorTd.textContent = vendor.text
    tr.appendChild(vendorTd)

    const buttonTd = document.createElement("td")

    const vendorHidden = document.createElement("input")
    vendorHidden.type = "hidden"
    vendorHidden.name = `assignments[${this.assignmentIndexValue}][vendor_id]`
    vendorHidden.value = vendor.value

    const roleHidden = document.createElement("input")
    roleHidden.type = "hidden"
    roleHidden.name = `assignments[${this.assignmentIndexValue}][role]`
    roleHidden.value = role.value

    const removeBtn = document.createElement("button")
    removeBtn.type = "button"
    removeBtn.textContent = "Remove"
    removeBtn.addEventListener("click", () => tr.remove())

    buttonTd.appendChild(vendorHidden)
    buttonTd.appendChild(roleHidden)
    buttonTd.appendChild(removeBtn)
    tr.appendChild(buttonTd)

    assignments.appendChild(tr)
  }

  onModeChange() {
    const buttons = Array.from(document.querySelectorAll("input[name='mode']"))
    const checked = buttons.find((b) => b.checked)
    const custom = document.querySelector("#settings-custom")
    if (!custom) return

    custom.style.display = checked && checked.value === "custom" ? "" : "none"
  }

  onActivityPaginateClick() {
    window.Turbolinks?.ProgressBar?.start?.()
    window.Turbolinks?.ProgressBar?.advanceTo?.(25)
  }
}
