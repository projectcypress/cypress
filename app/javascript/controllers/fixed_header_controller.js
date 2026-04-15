// fixed_header_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header"]
  static values = {
    topOffset: { type: Number, default: 0 } // set if you already have a fixed navbar
  }

  connect() {
    this.isFixed = false
    this.spacer = null

    this.onScroll = this.processScroll.bind(this)
    this.onResize = this.measure.bind(this)

    this.measure()
    window.addEventListener("scroll", this.onScroll, { passive: true })
    window.addEventListener("resize", this.onResize)
    this.processScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    window.removeEventListener("resize", this.onResize)
    this.unfix()
  }

  measure() {
    const scrollTop = window.scrollY || document.documentElement.scrollTop
    this.originalTop = this.headerTarget.getBoundingClientRect().top + scrollTop
    this.height = this.headerTarget.getBoundingClientRect().height
  }

  processScroll() {
    if (this.element.offsetParent === null) return

    const scrollTop = window.scrollY || document.documentElement.scrollTop
    const shouldFix = scrollTop >= (this.originalTop - this.topOffsetValue)

    if (shouldFix) this.fix()
    else this.unfix()
  }

  fix() {
    if (this.isFixed) return
    this.isFixed = true

    // prevent layout jump
    this.spacer = document.createElement("div")
    this.spacer.style.height = `${this.height}px`
    this.headerTarget.parentNode.insertBefore(this.spacer, this.headerTarget)

    // Bootstrap 5 fixed positioning
    this.headerTarget.classList.add("fixed-top", "w-100")
    this.headerTarget.style.top = `${this.topOffsetValue}px` // override if you need an offset
  }

  unfix() {
    if (!this.isFixed) return
    this.isFixed = false

    this.headerTarget.classList.remove("fixed-top", "w-100")
    this.headerTarget.style.top = ""

    if (this.spacer) {
      this.spacer.remove()
      this.spacer = null
    }
  }
}
