import { Controller } from "@hotwired/stimulus"
import * as cypress from "cypress"

export default class extends Controller {
  static values = { initialized: Boolean }

  connect() {
    // Optional: run once on first connect
    if (!this.initializedValue) this.init()
  }

  init() {
    cypress.initializeJqueryCvuRadio?.()
    cypress.initializeProductTable?.()
    cypress.reticulateSplines?.()
    cypress.initializeMeasureSelection?.()
    cypress.initializeActionModal?.()
    cypress.initializeAdmin?.()
    cypress.initializeChecklistTest?.()
    cypress.initializeCollapsible?.()
    cypress.initializeTestExecution?.()
    this.initializedValue = true
  }

  teardown() {
    cypress.teardown?.()
    this.initializedValue = false
  }
}
