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
    this.initializeMeasureSelection()

    // these rely on DOM that may be in the measure_selection partial
    this.readyRunOnRefreshBundle()
  }

  disconnect() {
    if (this._measureSelectionInitialized) {
      this.element.removeEventListener("change", this._boundHandleChange, true)
      this.element.removeEventListener("click", this._boundHandleClick, true)
      this._measureSelectionInitialized = false
    }

    if (this._searchTimer) clearTimeout(this._searchTimer)
    if (this._searchAbortController) this._searchAbortController.abort()
  }

  // -----------------------------
  // Fix: Rails adds hidden inputs for checkboxes.
  // Always resolve the *checkbox* (not the hidden field).
  // -----------------------------
  getCheckboxByName(name) {
    return Array.from(document.querySelectorAll(`input[name="${name}"]`)).find(
      (el) => el.type === "checkbox",
    )
  }

  // -----------------------------
  // CVU+ toggling (your existing behavior)
  // -----------------------------
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

    if (!checked || !checked.disabled) {
      if (this.hasVendorPatientsTarget) {
        this.setCheckboxDisabledNoUncheck(this.vendorPatientsTarget, !cvuplusChecked)
      }
      if (this.hasBundlePatientsTarget) {
        this.setCheckboxDisabledNoUncheck(this.bundlePatientsTarget, !cvuplusChecked)
      }

      if (this.hasC1TestTarget) this.setCheckboxDisabledNoUncheck(this.c1TestTarget, cvuplusChecked)
      if (this.hasC2TestTarget) this.setCheckboxDisabledNoUncheck(this.c2TestTarget, cvuplusChecked)
      if (this.hasC3TestTarget) this.setCheckboxDisabledNoUncheck(this.c3TestTarget, cvuplusChecked)
      if (this.hasC4TestTarget) this.setCheckboxDisabledNoUncheck(this.c4TestTarget, cvuplusChecked)
    }

    if (this.hasBundleOptionsTarget) this.setElementHidden(this.bundleOptionsTarget, !cvuplusChecked)
    if (this.hasCertificationOptionsTarget) this.setElementHidden(this.certificationOptionsTarget, cvuplusChecked)
    if (this.hasCertificationEditionTarget) this.setElementHidden(this.certificationEditionTarget, cvuplusChecked)
  }

  // -----------------------------
  // Measure selection behavior (wiring)
  // -----------------------------
  initializeMeasureSelection() {
    if (this._measureSelectionInitialized) return
    this._measureSelectionInitialized = true

    this._boundHandleChange = this.handleChange.bind(this)
    this._boundHandleClick = this.handleClick.bind(this)

    // capture=true so we keep catching events even if DOM is replaced
    this.element.addEventListener("change", this._boundHandleChange, true)
    this.element.addEventListener("click", this._boundHandleClick, true)
  }

  /* eslint-disable max-statements */
  handleChange(event) {
    const el = event.target

    // Measure selection radio buttons
    if (el.matches('.form-check input[name="product[measure_selection]"]')) {
      if (el.disabled) return
      const selection = el.value

      if (selection === "custom") {
        this.ToggleCustomSelection("open")
      } else {
        this.ToggleCustomSelection("close")
        this.CheckMany(selection)
      }
      return
    }

    // Bundle change
    if (el.matches('.form-check input[name="product[bundle_id]"]')) {
      if (el.disabled) return
      this.UpdateMeasureSet(el.value)
      return
    }

    // C2 test -> duplicate patients
    // IMPORTANT: only act on the actual checkbox (not Rails' hidden field)
    if (el.matches('.form-check input[name="product[c2_test]"][type="checkbox"]')) {
      if (el.disabled) return

      const c2Checked = Boolean(el.checked)
      const dup = document.querySelector("#product_duplicate_patients")
      if (dup) {
        this.setCheckboxDisabled(dup, !c2Checked)
        dup.checked = c2Checked
      }
      return
    }

    // CVU+ -> duplicate patients
    if (el.matches('.form-check input[name="product[cvuplus]"]')) {
      if (el.disabled) return

      const cvuPlus = el.value // "true"/"false"
      const c2Checkbox = this.getCheckboxByName("product[c2_test]")
      const c2Checked = Boolean(c2Checkbox && c2Checkbox.checked)

      const dup = document.querySelector("#product_duplicate_patients")
      if (dup) {
        this.setCheckboxDisabled(dup, cvuPlus === "false" && !c2Checked)
        dup.checked = cvuPlus === "true" || c2Checked
      }
      return
    }

    // Measure group-all checkbox (select all in category)
    if (el.matches(".measure-group-all")) {
      this.handleMeasureGroupAllChanged(el)
      return
    }

    // Individual measure checkbox
    if (el.matches(".measure-checkbox")) {
      this.UpdateGroupSelections(el)
      return
    }
  }
  /* eslint-enable max-statements */

  handleClick(event) {
    // Enable changing measures
    const measuresBtn = event.target.closest("#measures_options button")
    if (measuresBtn) {
      event.preventDefault()

      document
        .querySelectorAll('.measure-group [type="checkbox"]')
        .forEach((cb) => (cb.disabled = false))

      document
        .querySelectorAll('input[name="product[measure_selection]"]')
        .forEach((radio) => {
          radio.disabled = false
          const container = radio.closest(".radio")
          if (container) container.classList.remove("disabled")
        })

      const alertEl = measuresBtn.closest(".alert") || measuresBtn.closest("alert")
      if (alertEl) {
        const closeBtn =
          alertEl.querySelector(".close") ||
          alertEl.querySelector('[data-bs-dismiss="alert"]') ||
          alertEl.querySelector('[data-dismiss="alert"]')
        if (closeBtn) closeBtn.click()
      }
      return
    }

    // Clear measures button
    const clearBtn = event.target.closest(".clear-measures-btn")
    if (clearBtn) {
      event.preventDefault()

      this.element
        .querySelectorAll(".measure-group .measure-checkbox")
        .forEach((cb) => {
          cb.checked = false
          cb.dispatchEvent(new Event("change", { bubbles: true }))
        })

      clearBtn.blur()
    }
  }

  // -----------------------------
  // Ported functions: ToggleCustomSelection / CheckMany / UpdateMeasureSet
  // -----------------------------
  ToggleCustomSelection(task) {
    const view = this.element.querySelector(".select-measures") || document.querySelector(".select-measures")
    if (!view) return

    const isHidden = view.classList.contains("d-none")
    if (task === "close" && !isHidden) view.classList.add("d-none")
    if (task === "open" && isHidden) view.classList.remove("d-none")
  }

  CheckMany(group) {
    const all = Array.from(document.querySelectorAll(".measure-group .measure-checkbox"))
    if (all.length === 0) return

    const fireChange = (cb) => cb.dispatchEvent(new Event("change", { bubbles: true }))
    const isRetired = (cb) => cb.dataset && cb.dataset.category === "Retired"

    if (group === "all") {
      all.forEach((cb) => {
        if (!cb.checked) {
          cb.checked = true
          fireChange(cb)
        }
      })

      all.filter(isRetired).forEach((cb) => {
        if (cb.checked) {
          cb.checked = false
          fireChange(cb)
        }
      })
      return
    }

    all.forEach((cb) => {
      const type = cb.dataset ? cb.dataset.measureType : null
      const shouldBeChecked = type === group

      if (cb.checked !== shouldBeChecked) {
        cb.checked = shouldBeChecked
        fireChange(cb)
      }
    })

    all.filter(isRetired).forEach((cb) => {
      if (cb.checked) {
        cb.checked = false
        fireChange(cb)
      }
    })
  }

  async UpdateMeasureSet(bundle_id) {
    const section = document.querySelector("#measure_selection_section")
    if (!section) return

    section.innerHTML = ""

    try {
      const resp = await fetch(`/bundles/${bundle_id}/measures/grouped`, {
        method: "GET",
        headers: { Accept: "text/html" },
        credentials: "same-origin",
      })
      if (!resp.ok) throw new Error(`${resp.status} ${resp.statusText}`)

      section.innerHTML = await resp.text()

      // Re-hook behaviors for reloaded measures UI
      this.readyRunOnRefreshBundle()
    } catch (err) {
      alert("Sorry, we can't currently produce measures for that bundle. " + err)
    }
  }

  // -----------------------------
  // Added functions: HookupProductSearch + filtering + "ready_run_on_refresh_bundle" + UpdateGroupSelections
  // -----------------------------
  HookupProductSearch(searchInputEl) {
    const bundles = Array.from(document.querySelectorAll('input[name="product[bundle_id]"]'))
    const checked = bundles.find((b) => b.checked)
    const bundle_id = (checked && checked.value) || (bundles[0] && bundles[0].value)
    if (!bundle_id) return

    const raw = (searchInputEl && searchInputEl.value ? searchInputEl.value : "").replace(/[!'()*]/g, "")
    const current_search = encodeURIComponent(raw)

    if (this._searchTimer) clearTimeout(this._searchTimer)
    if (this._searchAbortController) this._searchAbortController.abort()

    this._searchAbortController = new AbortController()
    const signal = this._searchAbortController.signal

    this._searchTimer = setTimeout(async () => {
      try {
        const resp = await fetch(`/bundles/${bundle_id}/measures/filtered/${current_search}`, {
          method: "GET",
          headers: { Accept: "application/json" },
          credentials: "same-origin",
          signal,
        })
        if (!resp.ok) return

        const data = await resp.json()
        this.filterVisibleMeasures(searchInputEl, data.measures || [])
        this.filterVisibleMeasureTabs(searchInputEl, data.measure_tabs || {})
      } catch (e) {
        // ignore aborts
      }
    }, 200)
  }

  filterVisibleMeasures(searchInputEl, returned_measures) {
    const measures = Array.from(document.querySelectorAll(".measure-group .checkbox"))
    const q = (searchInputEl && searchInputEl.value) || ""

    if (q === "") {
      measures.forEach((el) => (el.style.display = ""))
      return
    }

    const set = new Set(returned_measures)
    measures.forEach((el) => {
      el.style.display = set.has(el.id) ? "" : "none"
    })
  }

  filterVisibleMeasureTabs(searchInputEl, measure_tabs_response) {
    const tabs = Array.from(document.querySelectorAll("[role='tablist'] [role='tab']"))

    tabs.forEach((tab) => {
      const current_tab_name = tab.getAttribute("aria-controls")
      if (current_tab_name && Reflect.apply(Object.prototype.hasOwnProperty, measure_tabs_response, [current_tab_name])) {
        tab.style.display = ""
        const link = tab.querySelector("a")
        if (link) {
          const children = Array.from(link.children)
          link.textContent = measure_tabs_response[current_tab_name]
          children.forEach((c) => link.appendChild(c))
        }
      } else {
        tab.style.display = "none"
      }
    })

    const active = document.querySelector("[role='tablist'] [role='tab'].ui-tabs-active")
    if (active && active.style.display === "none") {
      const firstVisible = tabs.find((t) => t.style.display !== "none")
      if (firstVisible) firstVisible.click()
    }
  }

  readyRunOnRefreshBundle() {
    if (window.jQuery && window.jQuery.fn && typeof window.jQuery.fn.tabs === "function") {
      const $ = window.jQuery
      if ($("#measure_tabs").length) {
        $("#measure_tabs").tabs().addClass("ui-tabs-vertical ui-helper-clearfix")
        $("#measure_tabs > ul > li").removeClass("ui-corner-top")
      }
    }

    document
      .querySelectorAll(".measure-group .measure-checkbox:checked")
      .forEach((cb) => cb.dispatchEvent(new Event("change", { bubbles: true })))

    const checkedMeasureSelection = document.querySelector('input[name="product[measure_selection]"]:checked')
    if (checkedMeasureSelection) checkedMeasureSelection.dispatchEvent(new Event("change", { bubbles: true }))

    const checkedCvu = document.querySelector('input[name="product[cvuplus]"]:checked')
    if (checkedCvu) checkedCvu.dispatchEvent(new Event("change", { bubbles: true }))

    const search = document.querySelector("#product_search_measures")
    if (search) {
      search.onkeypress = (event) => {
        if (event.keyCode === 13) return false
      }
      search.onkeyup = () => this.HookupProductSearch(search)
    }
  }

  handleMeasureGroupAllChanged(groupAllEl) {
    const group = groupAllEl.closest(".measure-group")
    if (!group) return

    const category = this.escapeCSS(groupAllEl.getAttribute("id") || "")
    const boxes = Array.from(group.querySelectorAll(`.measure-checkbox[data-category="${category}"]`))

    boxes.forEach((cb) => {
      cb.checked = groupAllEl.checked
      cb.dispatchEvent(new Event("change", { bubbles: true }))
      cb.dispatchEvent(new Event("groupclick", { bubbles: true }))
    })
  }

  UpdateGroupSelections(measureCheckboxEl) {
    const measure_category = this.escapeCSS(measureCheckboxEl.getAttribute("data-category") || "")

    const groupChecks = Array.from(
      document.querySelectorAll(`.measure-group .measure-checkbox[data-category="${measure_category}"]`),
    )

    const groupIsSelected = groupChecks.every((cb) => cb.checked)

    const groupAll = document.querySelector(`.measure-group-all[id="${measure_category}"]`)
    if (groupAll) groupAll.checked = groupIsSelected

    const number_checked = groupChecks.filter((cb) => cb.checked).length

    const tabCountEl = document.querySelector(
      `#measure_tabs .ui-tabs-nav [href*="${measure_category}"] .selected-number`,
    )
    if (tabCountEl) {
      tabCountEl.innerHTML =
        number_checked > 0
          ? `${number_checked}<i aria-hidden="true" class="fas fa-fw fa-check"></i>`
          : ""
    }

    const overallCountEl = document.querySelector(".select-measures .card-title .selected-number")
    if (overallCountEl) {
      const total = document.querySelectorAll(".measure-group .measure-checkbox:checked").length
      overallCountEl.innerHTML =
        total > 0 ? `${total}<i aria-hidden="true" class="fas fa-fw fa-check"></i>` : "(0)"
    }
  }

  escapeCSS(value) {
    if (window.CSS && typeof window.CSS.escape === "function") return window.CSS.escape(value)
    return String(value).replace(/[!"#$%&'()*+,./:;<=>?@[\\\]^`{|}~]/g, "\\$&")
  }

  // -----------------------------
  // Helpers
  // -----------------------------
  setCheckboxDisabled(inputOrSelector, state) {
    const inputEl =
      typeof inputOrSelector === "string"
        ? document.querySelector(inputOrSelector)
        : inputOrSelector
    if (!inputEl) return

    const disabled = Boolean(state)
    const container =
      inputEl.closest(".form-check") ||
      inputEl.closest(".radio") ||
      inputEl.closest(".form-group") ||
      inputEl

    container.classList.toggle("disabled", disabled)

    inputEl.disabled = disabled
    container.querySelectorAll("input, select, textarea, button").forEach((node) => {
      node.disabled = disabled
    })

    if (disabled) inputEl.checked = false
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
