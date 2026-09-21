import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.$ = window.jQuery;
    if (!this.$) return;

    this.initializeTabs();

    this._boundMultiUploadChange = this.onMultiUploadChange.bind(this);
    document.addEventListener("change", this._boundMultiUploadChange, true);
  }

  disconnect() {
    if (this._boundMultiUploadChange) {
      document.removeEventListener(
        "change",
        this._boundMultiUploadChange,
        true,
      );
    }
  }

  initializeTabs() {
    if (!this.$.fn || typeof this.$.fn.tabs !== "function") return;

    this.$(".product-test-tabs").each((_i, el) => {
      const $el = this.$(el);
      if (!$el.hasClass("ui-tabs")) $el.tabs();
      $el.find("> ul > li").removeClass("ui-corner-top");
    });
  }

  onMultiUploadChange(ev) {
    const input = ev.target;
    if (!(input instanceof Element)) return;
    if (!input.matches(".multi-upload-field")) return;

    const parent = input.parentElement;
    const submit =
      parent && parent.parentElement
        ? parent.parentElement.querySelector(":scope > .multi-upload-submit")
        : null;

    if (submit instanceof HTMLElement) submit.click();
  }
}
