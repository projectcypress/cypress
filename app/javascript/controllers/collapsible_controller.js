// collapsible_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._boundClick = this.onClick.bind(this)
    // delegated so it works for dynamic content
    document.addEventListener("click", this._boundClick, true)
  }

  disconnect() {
    document.removeEventListener("click", this._boundClick, true)
  }

  onClick(event) {
    const trigger = event.target.closest(".collapsible")
    if (!trigger) return

    trigger.classList.toggle("active")

    const content = trigger.nextElementSibling
    if (!content) return

    const isOpen = content.style.display === "block"
    content.style.display = isOpen ? "none" : "block"
  }
}
