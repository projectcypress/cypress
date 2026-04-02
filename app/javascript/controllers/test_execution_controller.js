// test_execution_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectExecution", "form", "fileErrorTabs", "xmlErrorTabs"]

  connect() {
    this.initializeResultsUI()
  }

  // If you use turbo caching, consider also wiring:
  // data-action="turbo:before-cache@document->test-execution#beforeCache"
  beforeCache() {
    this.teardownResultsUI()
  }

  disconnect() {
    this.teardownResultsUI()
  }

  viewExecution() {
    const url = this.selectExecutionTarget?.value
    if (url) window.location.href = url
  }

  // TODO: Not Sure this is used?
  // submitUpload(event) {
  //   event.preventDefault()
  //   this.formTarget?.requestSubmit?.() || this.formTarget?.submit?.()
  // }

  popoverShow(event) {
    // event.target is the button
    const labelNode = event.target?.children?.[1]
    if (!labelNode) return
    labelNode.innerText = labelNode.innerText.replace("view", "hide")
  }

  popoverHide(event) {
    const labelNode = event.target?.children?.[1]
    if (!labelNode) return
    labelNode.innerText = labelNode.innerText.replace("hide", "view")
  }

  initializeResultsUI() {
    // Guard: only run if the relevant DOM exists on this page
    if (!this.hasFileErrorTabsTarget && this.xmlErrorTabsTargets.length === 0) return
    if (!window.$?.fn?.tabs) return // jQuery UI tabs not loaded

    if (this.hasFileErrorTabsTarget) {
      window.$(this.fileErrorTabsTarget)
        .tabs()
        .addClass("ui-tabs-vertical ui-helper-clearfix")
        .removeClass("ui-widget")
        .removeClass("hidden")

      window.$(this.fileErrorTabsTarget).find("> ul > li").removeClass("ui-corner-top")
    }

    this.xmlErrorTabsTargets.forEach((el) => {
      const $el = window.$(el)

      const disabledTabs = []
      const enabledTabs = []

      $el.find("li").each(function (index) {
        if (window.$(this).find("span").text() === "(0)") disabledTabs.push(index)
        else enabledTabs.push(index)
      })

      $el.tabs({ active: enabledTabs[0] ?? 0, disabled: disabledTabs })
      $el.find("> ul > li").removeClass("ui-corner-top")
    })
  }

  teardownResultsUI() {
    // Prevent “tabs already initialized” issues on Turbo restores
    if (!window.$?.fn?.tabs) return

    if (this.hasFileErrorTabsTarget) {
      const $el = window.$(this.fileErrorTabsTarget)
      if ($el.data("ui-tabs")) $el.tabs("destroy")
    }

    this.xmlErrorTabsTargets.forEach((el) => {
      const $el = window.$(el)
      if ($el.data("ui-tabs")) $el.tabs("destroy")
    })
  }
}
