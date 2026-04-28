import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text"]

  toggle(event) {
    event.preventDefault()
    this.textTarget.classList.toggle("show")
  }
}
