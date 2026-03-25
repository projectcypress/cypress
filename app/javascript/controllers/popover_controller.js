// error_popup_button_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["text"];

  connect() {
    const Popover = window.bootstrap?.Popover;
    if (!Popover) return;

    this.popover = Popover.getOrCreateInstance(this.element);

    this._onShow = () => {
      this.textTarget.textContent = this.textTarget.textContent.replace("view", "hide");
    };
    this._onHidden = () => {
      this.textTarget.textContent = this.textTarget.textContent.replace("hide", "view");
    };

    this.element.addEventListener("show.bs.popover", this._onShow);
    this.element.addEventListener("hidden.bs.popover", this._onHidden);
  }

  disconnect() {
    this.element.removeEventListener("show.bs.popover", this._onShow);
    this.element.removeEventListener("hidden.bs.popover", this._onHidden);
    this.popover?.dispose?.();
  }
}
