// checklist_modal_filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  filter(event) {
    const input = event.target
    if (!(input instanceof HTMLInputElement)) return

    const filterValue = (input.value || "").toUpperCase()
    const { index, suffix } = this.resolveIndexAndSuffix(input)
    if (index == null) return

    const ul = document.getElementById(`lookup_codes${index}${suffix}`)
    if (!ul) return

    Array.from(ul.getElementsByTagName("li")).forEach((li) => {
      const text = (li.querySelector("i")?.textContent || li.textContent || "").toUpperCase()
      li.style.display = text.includes(filterValue) ? "" : "none"
    })
  }

  preventEnter(event) {
    if (event.key === "Enter") event.preventDefault()
  }

  resolveIndexAndSuffix(input) {
    const index = input.dataset.index
    const suffix = input.dataset.suffix ?? ""
    if (index != null) return { index, suffix }

    const id = input.id || ""
    if (!id.startsWith("lookupFilter")) return { index: null, suffix: "" }

    const rest = id.replace(/^lookupFilter/, "")
    const m = rest.match(/^(\d+)(.*)$/)
    if (!m) return { index: rest, suffix: "" }

    return { index: m[1], suffix: m[2] || "" }
  }
}
