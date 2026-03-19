import { Controller } from "@hotwired/stimulus";
import "@hotwired/turbo-rails"

// Connects data-controller="bundle-list"
export default class extends Controller {
  connect() {
    this.tick = this.tick.bind(this)

    // run immediately, then every 2s
    this.tick()
    this.timer = setInterval(this.tick, this.interval())
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  async tick() {
    const response = await fetch(this.url(), {
      headers: { Accept: "text/vnd.turbo-stream.html" }
    })

    if (!response.ok) return

    const streamHtml = await response.text()
    
    if (window.Turbo?.renderStreamMessage) {
      window.Turbo.renderStreamMessage(streamHtml)
    } else {
      window.Turbo.session.renderStreamMessage(streamHtml)
    }

    // keep your existing hook if you need it
    document.dispatchEvent(new CustomEvent("cypress:init"))
  }

  url() {
    return this.element.dataset.url
  }

  interval() {
    return Number(this.element.dataset.interval || 2000)
  }
}
