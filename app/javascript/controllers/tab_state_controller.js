import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.$ = window.jQuery;
    if (!this.$) return;

    this.jqueryUiHandler = this.saveJqueryUiTabState.bind(this);

    this.$(document).on("tabsactivate", this.jqueryUiHandler);
    this.restoreAllTabState();
  }

  disconnect() {
    if (this.$) {
      this.$(document).off("tabsactivate", this.jqueryUiHandler);
    }
  }

  storageKey() {
    return `tab-state:${window.location.pathname}`;
  }

  readState() {
    try {
      return JSON.parse(sessionStorage.getItem(this.storageKey()) || "{}");
    } catch {
      return {};
    }
  }

  writeState(state) {
    sessionStorage.setItem(this.storageKey(), JSON.stringify(state));
  }

  saveJqueryUiTabState(event, ui) {
    const container = event.target;
    if (!(container instanceof Element)) return;
    if (!this.element.contains(container)) return;
    if (!container.id) return;

    const newTab = ui?.newTab?.[0];
    if (!newTab) return;

    const index = Array.from(newTab.parentElement.children).indexOf(newTab);

    const state = this.readState();
    state[container.id] = {
      type: "jquery-ui",
      active: index
    };
    this.writeState(state);
  }

  restoreAllTabState() {
    const state = this.readState();

    Object.entries(state).forEach(([containerId, config]) => {
      const container = document.getElementById(containerId);
      if (!container || !this.element.contains(container)) return;

      if (config.type === "jquery-ui") {
        this.restoreJqueryUiTab(container, config);
      }

    });
  }

  restoreJqueryUiTab(container, config) {
    if (!this.$?.fn || typeof this.$.fn.tabs !== "function") return;
    if (typeof config.active !== "number") return;

    const $container = this.$(container);

    if (!$container.hasClass("ui-tabs")) {
      $container.tabs();
    }

    $container.tabs("option", "active", config.active);
  }
}
