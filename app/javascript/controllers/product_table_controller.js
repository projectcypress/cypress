// product_table_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.$ = window.jQuery;
    if (!this.$) return;

    this.initializeTabs();
    this.initializeDataTables();

    this._boundMultiUploadChange = this.onMultiUploadChange.bind(this);
    document.addEventListener("change", this._boundMultiUploadChange, true);

    this._boundBeforeStreamRender = this.onBeforeStreamRender.bind(this);
    document.addEventListener(
      "turbo:before-stream-render",
      this._boundBeforeStreamRender,
    );
  }

  disconnect() {
    if (this._boundMultiUploadChange) {
      document.removeEventListener(
        "change",
        this._boundMultiUploadChange,
        true,
      );
    }

    if (this._boundBeforeStreamRender) {
      document.removeEventListener(
        "turbo:before-stream-render",
        this._boundBeforeStreamRender,
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

  initializeDataTables() {
    if (!this.$.fn || typeof this.$.fn.DataTable !== "function") return;
    const isDT = (elOrSelector) =>
      this.$.fn.dataTable.isDataTable(elOrSelector);

    this.$(".user_tests_table:visible").each((_i, el) => {
      if (isDT(el)) return;
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
        order: [[4, "desc"]],
        autoWidth: false,
        deferRender: true,
      });
    });

    this.$(".vendor-table:visible").each((_i, el) => {
      if (isDT(el)) return;
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
        autoWidth: false,
        deferRender: true,
      });
    });

    this.$(".vendor-table-favorite:visible").each((_i, el) => {
      if (isDT(el)) return;
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
        autoWidth: false,
        deferRender: true,
      });
    });

    if (
      this.$("#display_filtering_test_status_display_body").length &&
      !isDT("#filtering_test_status_display")
    ) {
      this.$("#filtering_test_status_display").DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
        autoWidth: false,
        deferRender: true,
      });
    }

    this.$(".user_table:visible").each((_i, el) => {
      if (isDT(el)) {
        this.$(el).DataTable().columns.adjust().draw(false);
        return;
      }
      this.$(el).DataTable({
        searching: false,
        paging: true,
        lengthMenu: [
          [10, 25, 50, 100, -1],
          [10, 25, 50, 100, "All"],
        ],
        stateSave: true,
        info: false,
        columnDefs: [
          { orderable: true, className: "reorder", targets: [0, 1, 2] },
          { orderable: false, targets: "_all" },
        ],
        autoWidth: false,
        deferRender: true,
      });
    });

    this.$(".patient_table:visible").each((_i, el) => {
      if (isDT(el)) {
        this.$(el).DataTable().columns.adjust().draw(false);
        return;
      }
      this.$(el).DataTable({
        searching: false,
        paging: true,
        lengthMenu: [
          [10, 25, 50, 100, -1],
          [10, 25, 50, 100, "All"],
        ],
        stateSave: true,
        info: false,
        autoWidth: false,
        deferRender: true,
      });
    });

    this.$(".measure_tests_table:visible").each((_i, el) => {
      if (isDT(el)) return;
      this.$(el).DataTable({
        searching: false,
        paging: false,
        stateSave: true,
        info: false,
        autoWidth: false,
        deferRender: true,
      });
    });
  }

  /* eslint-disable max-statements */
  onBeforeStreamRender(event) {
    const streamElement = event.target;
    const action = streamElement.getAttribute("action");
    const targetId = streamElement.getAttribute("target");

    if (!["update", "replace"].includes(action)) return;
    if (!targetId?.startsWith("measure-tests-table-row-wrapper-")) return;

    const originalRender = event.detail.render;

    event.detail.render = (stream) => {
      const beforeTarget = document.getElementById(targetId);
      const beforeTable = beforeTarget?.closest("table.measure_tests_table");

      if (!beforeTable || !this.$.fn.dataTable.isDataTable(beforeTable)) {
        originalRender(stream);
        return;
      }

      const dataTable = this.$(beforeTable).DataTable();
      const headerCells = Array.from(beforeTable.querySelectorAll("thead th"));
      const tableRect = beforeTable.getBoundingClientRect();

      const previousTableWidth = beforeTable.style.width;
      const previousTableLayout = beforeTable.style.tableLayout;

      const lockedHeaderStyles = headerCells.map((cell) => ({
        width: cell.style.width,
        minWidth: cell.style.minWidth,
        maxWidth: cell.style.maxWidth,
        measuredWidth: `${cell.getBoundingClientRect().width}px`,
      }));

      const lockLayout = (table) => {
        table.style.width = `${tableRect.width}px`;
        table.style.tableLayout = "fixed";

        const currentHeaderCells = Array.from(
          table.querySelectorAll("thead th"),
        );
        lockedHeaderStyles.forEach((saved, index) => {
          const cell = currentHeaderCells[index];
          if (!cell) return;

          cell.style.width = saved.measuredWidth;
          cell.style.minWidth = saved.measuredWidth;
          cell.style.maxWidth = saved.measuredWidth;
        });
      };

      const unlockLayout = (table) => {
        if (!table) return;

        table.style.width = previousTableWidth;
        table.style.tableLayout = previousTableLayout;

        const currentHeaderCells = Array.from(
          table.querySelectorAll("thead th"),
        );
        lockedHeaderStyles.forEach((saved, index) => {
          const cell = currentHeaderCells[index];
          if (!cell) return;

          cell.style.width = saved.width;
          cell.style.minWidth = saved.minWidth;
          cell.style.maxWidth = saved.maxWidth;
        });
      };

      lockLayout(beforeTable);

      try {
        dataTable.destroy();
        originalRender(stream);

        const afterTarget = document.getElementById(targetId);
        const afterTable =
          afterTarget?.closest("table.measure_tests_table") || beforeTable;

        if (!afterTable) return;

        lockLayout(afterTable);

        const rebuilt = this.$(afterTable).DataTable({
          destroy: true,
          searching: false,
          paging: false,
          stateSave: true,
          info: false,
          autoWidth: false,
        });

        requestAnimationFrame(() => {
          try {
            rebuilt.columns.adjust().draw(false);
          } finally {
            unlockLayout(afterTable);
          }
        });
      } catch (error) {
        const currentTarget = document.getElementById(targetId);
        const currentTable =
          currentTarget?.closest("table.measure_tests_table") || beforeTable;
        unlockLayout(currentTable);
        throw error;
      }
    };
  }
  /* eslint-enable max-statements */

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
