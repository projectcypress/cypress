import { Controller } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 2000 },
    immediate: { type: Boolean, default: true },
    params: Object
  }

  connect() {
    this.stopped = false
    this.inFlight = false
    this.paused = false
    this.pageUrl = window.location.href
    this.abortController = null

    this.beforeCacheHandler = () => this.stop()
    this.beforeVisitHandler = () => this.pause()
    this.loadHandler = () => this.resume()

    document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
    document.addEventListener("turbo:before-visit", this.beforeVisitHandler)
    document.addEventListener("turbo:load", this.loadHandler)

    if (this.immediateValue) this.tick()
    this.timer = setInterval(() => this.tick(), this.intervalValue)
  }

  disconnect() {
    this.stop()

    document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
    document.removeEventListener("turbo:before-visit", this.beforeVisitHandler)
    document.removeEventListener("turbo:load", this.loadHandler)
  }

  stop() {
    this.stopped = true
    this.paused = true
    if (this.timer) clearInterval(this.timer)
    this.abortInFlight()
  }

  pause() {
    this.paused = true
    this.abortInFlight()
  }

  resume() {
    // When the new page loads, Stimulus will usually reconnect anyway,
    // but this keeps behavior safe if the controller persists.
    this.paused = false
    this.pageUrl = window.location.href
  }

  abortInFlight() {
    if (this.abortController) {
      try { this.abortController.abort() } catch (_) {}
      this.abortController = null
    }
  }

  async tick() {
    if (this.stopped || this.paused || this.inFlight) return
    if (document.visibilityState === "hidden") return

    this.inFlight = true
    this.abortController = new AbortController()

    try {
      const response = await fetch(this.buildUrl(), {
        signal: this.abortController.signal,
        headers: { Accept: "text/vnd.turbo-stream.html" },
        credentials: "same-origin"
      })

      if (!response.ok) return

      const html = await response.text()
      if (!html || html.trim().length === 0) return

      // Don’t apply updates if we navigated away
      if (this.stopped || this.paused) return
      if (window.location.href !== this.pageUrl) return

      if (window.Turbo?.renderStreamMessage) window.Turbo.renderStreamMessage(html)
      else window.Turbo.session.renderStreamMessage(html)
    } catch (e) {
      // Ignore aborts; rethrow/log other errors if you want
      if (e.name !== "AbortError") throw e
    } finally {
      this.inFlight = false
      this.abortController = null
    }
  }

  buildUrl() {
    const url = new URL(this.urlValue, window.location.origin)

    if (this.hasParamsValue && this.paramsValue) {
      Object.entries(this.paramsValue).forEach(([key, value]) => {
        if (value === null || value === undefined) return

        if (Array.isArray(value)) {
          url.searchParams.delete(key)
          value.forEach(v => url.searchParams.append(key, String(v)))
        } else {
          url.searchParams.set(key, String(value))
        }
      })
    }

    return url.toString()
  }
}
