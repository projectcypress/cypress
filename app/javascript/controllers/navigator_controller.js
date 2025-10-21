// navigator_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["first", "prev", "next", "last", "item"]
  static values = {
    index: { type: Number, default: 0 }
  }

  connect() {
    this.clampIndex()
  }

  first(event) {
    event?.preventDefault()
    this.indexValue = 0
    this.navigate()
  }

  prev(event) {
    event?.preventDefault()
    this.indexValue -= 1
    this.clampIndex()
    this.navigate()
  }

  next(event) {
    event?.preventDefault()
    this.indexValue += 1
    this.clampIndex()
    this.navigate()
  }

  last(event) {
    event?.preventDefault()
    this.indexValue = this.itemTargets.length - 1
    this.clampIndex()
    this.navigate()
  }

  setIndexFromHref(href) {
    const idx = this.itemTargets.findIndex(el => el.getAttribute("href") === href)
    if (idx !== -1) this.indexValue = idx
  }

  navigate() {
    const el = this.itemTargets[this.indexValue]
    if (!el) return

    const href = el.getAttribute("href")

    // Replace the old "action(tgt)" with an event you can handle elsewhere
    this.element.dispatchEvent(new CustomEvent("navigator:navigate", {
      bubbles: true,
      detail: { href, index: this.indexValue, element: el }
    }))

    // Or, if you just want to go there:
    // window.location.href = href
  }

  clampIndex() {
    if (!Number.isFinite(this.indexValue)) this.indexValue = 0
    if (this.indexValue < 0) this.indexValue = 0
    const max = this.itemTargets.length - 1
    if (this.indexValue > max) this.indexValue = Math.max(0, max)
  }
}
