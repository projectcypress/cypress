export function initializeDatatable() {
  $(".user_table").DataTable({
    destroy: true,
    searching: false,
    paging: true,
    lengthMenu: [
      [10, 25, 50, 100, -1],
      [10, 25, 50, 100, "All"],
    ],
    stateSave: true /* preserves order on reload */,
    info: false,
    columnDefs: [
      { orderable: true, className: "reorder", targets: [0, 1, 2] },
      { orderable: false, targets: "_all" },
    ],
  });

  $(".patient_table").DataTable({
    destroy: true,
    searching: false,
    paging: true,
    lengthMenu: [
      [10, 25, 50, 100, -1],
      [10, 25, 50, 100, "All"],
    ],
    stateSave: true /* preserves order on reload */,
    info: false,
  });

  $(".measure_tests_table").DataTable({
    destroy: true,
    searching: false,
    paging: false,
    stateSave: true,
    info: false,
  });
}
