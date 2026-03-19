import { Controller } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 2000 },
    immediate: { type: Boolean, default: true }
  }

  connect() {
    this.stopped = false
    this.inFlight = false
    if (this.immediateValue) this.tick()
    this.timer = setInterval(() => this.tick(), this.intervalValue)
  }

  disconnect() {
    this.stopped = true
    if (this.timer) clearInterval(this.timer)
  }

  async tick() {
    if (this.stopped || this.inFlight) return
    this.inFlight = true

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "text/vnd.turbo-stream.html" }
      })
      if (!response.ok) return

      const html = await response.text()
      if (!html || html.trim().length === 0) return

      if (window.Turbo?.renderStreamMessage) window.Turbo.renderStreamMessage(html)
      else window.Turbo.session.renderStreamMessage(html)

      document.dispatchEvent(new CustomEvent("cypress:init"))

    } finally {
      this.inFlight = false
    }
  }
}