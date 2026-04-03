import * as cypress from "cypress"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { initialized: Boolean }

  connect() {
    if (this.initializedValue) return
    this.initializedValue = true

    cypress.reticulateSplines?.()
    cypress.initializeActionModal?.()
    cypress.initializeAdmin?.()
    cypress.initializeChecklistTest?.()
    cypress.initializeRecord?.()
    cypress.initializeInfiniteScroll?.()
    cypress.updateBundleStatus?.()
  }

  teardown() {
    cypress.teardown?.()
    this.initializedValue = false
  }

  disconnect() {
    // optional: if you want cleanup when controller is removed
    // cypress.teardown?.()
    // this.initializedValue = false
  }
}
