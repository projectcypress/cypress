// infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { loadNextPageAt: { type: Number, default: 3000 } }

  connect() {
    this._nextPageFnRunning = false
    this._boundCheckAndLoad = this.checkAndLoad.bind(this)
    this._boundOnClick = this.onClick.bind(this)

    window.addEventListener("scroll", this._boundCheckAndLoad, { passive: true })
    this.element.addEventListener("click", this._boundOnClick)

    this.checkAndLoad()
  }

  disconnect() {
    window.removeEventListener("scroll", this._boundCheckAndLoad)
    this.element.removeEventListener("click", this._boundOnClick)
  }

  onClick(event) {
    const link = event.target.closest("#view-more a")
    if (!link) return
    event.preventDefault()
    this.nextPage()
  }

  approachingBottomOfPage() {
    const scrollTop = window.scrollY || document.documentElement.scrollTop || 0
    const docHeight = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)
    const winHeight = window.innerHeight || document.documentElement.clientHeight || 0
    return scrollTop > docHeight - winHeight - this.loadNextPageAtValue
  }

  async nextPage() {
    const viewMore = this.element.querySelector("#view-more")
    const loadingMore = this.element.querySelector("#loading-more")
    const url = viewMore?.querySelector("a")?.getAttribute("href")
    if (this._nextPageFnRunning || !url) return

    viewMore?.classList.add("d-none")
    loadingMore?.classList.remove("d-none")
    this._nextPageFnRunning = true

    try {
      const resp = await fetch(url, {
        method: "GET",
        headers: { Accept: "text/javascript", "X-Requested-With": "XMLHttpRequest" },
        credentials: "same-origin",
      })
      const js = await resp.text()
      ;(0, eval)(js)
    } finally {
      this._nextPageFnRunning = false
      viewMore?.classList.remove("d-none")
      loadingMore?.classList.add("d-none")
    }
  }

  checkAndLoad() {
    if (this.approachingBottomOfPage()) this.nextPage()
  }
}
