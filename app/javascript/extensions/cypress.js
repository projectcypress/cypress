function changePanel() {
  var checked = $("input:checked");
  if (checked.length > 0) {
    // Make remove panel visable
    $(".checkbox-danger-panel").toggleClass("d-none");
  } else {
    // Make remove panel invisible
    $(".checkbox-danger-panel").toggleClass("d-none");
  }
}



// function show_error_popup_and_jump(href) {
//   if ($(href)) {
//     document.querySelectorAll("button.error-popup-btn").forEach((btn) => {
//       window.bootstrap?.Popover?.getInstance(btn).hide();
//     }); /* hide all error popovers before showing the new one */

//     var scroll_time = 300; /* (milisec) time it takes to scroll from one error popover to another */
//     var height_buffer = 20; /* number of pixels between the xml_nav_bar and the error after done scrolling */

//     var height_of_xmlnav_div = $(".xml-nav").outerHeight();
//     var height_of_error_div = $(href).siblings(".error").outerHeight();
//     var pixels_down_page =
//       height_of_xmlnav_div +
//       height_buffer +
//       height_of_error_div; /* number of pixels down the page the error will apear after scrolling */

//     /* scroll to error popover */
//     $("html,body")
//       .animate(
//         { scrollTop: $(href).offset().top - pixels_down_page },
//         { duration: scroll_time, easing: "swing" },
//       )
//       .promise()
//       .done(function () {
//         const selector = "button." + href.replace("#", "");
//         const btn = document.querySelector(selector);
//         if (btn) {
//           window.bootstrap?.Popover?.getInstance(btn).toggle();
//         } /* show popover for button with matching error id class */

//         var $list_item = $("li." + href.replace("#", ""));
//         if ($list_item.length) {
//           $list_item.effect(
//             "highlight",
//             {},
//             2000,
//           ); /* temporarily highlight the error if there are a list of errors in the popover */
//         }
//       });
//   }
// }

var approachingBottomOfPage,
  loadNextPageAt,
  nextPage,
  nextPageFnRunning,
  viewMore,
  checkAndLoad;

nextPageFnRunning = false;
loadNextPageAt = 3000;

approachingBottomOfPage = function () {
  return (
    $(window).scrollTop() >
    $(document).height() - $(window).height() - loadNextPageAt
  );
};

nextPage = function () {
  var loadingMore, url;
  viewMore = $("#view-more");
  loadingMore = $("#loading-more");
  url = viewMore.find("a").attr("href");
  if (nextPageFnRunning || !url) {
    return;
  }
  viewMore.hide();
  loadingMore.show();
  nextPageFnRunning = true;
  return $.ajax({
    url: url,
    method: "GET",
    dataType: "script",
  }).always(function () {
    nextPageFnRunning = false;
    viewMore.show();
    return loadingMore.hide();
  });
};

// Checks to see if we are close to the bottom of the page and if we are load more measures
checkAndLoad = function () {
  if (approachingBottomOfPage()) {
    return nextPage();
  }
};

function escapeCSS(str) {
  return str.replace(/[!"#$%&'()*+,./:;<=>?@[\\\]^`{|}~]/g, "\\$&");
}

function lookupLabelFunction(index) {
  // Declare variables
  var input, checkbox;
  input = document.getElementById("code" + index);
  if (input !== null) {
    checkbox = document.getElementById(
      "product_test_checked_criteria_attributes_" + index + "_negated_valueset",
    );
    if (checkbox.checked == true) {
      $("div#code" + index).hide();
      $("div#vs" + index).show();
    } else {
      $("div#vs" + index).hide();
      $("div#code" + index).show();
    }
  }
}

export function initializeActionModal() {
  /* edit text in modal with text from specific object form */
  $(document).on("show.bs.modal", "#action_modal", function (e) {
    $(this)
      .find(".modal-content .modal-title")
      .text($(e.relatedTarget).attr("data-title"));
    $(this)
      .find(".modal-body p.warning_message")
      .text($(e.relatedTarget).attr("data-message"));
    $(this)
      .find(".modal-body span.object_type")
      .text($(e.relatedTarget).attr("data-object-type"));
    $(this)
      .find(".modal-body strong.object_name")
      .text($(e.relatedTarget).attr("data-object-name"));
    $(this)
      .find(".modal-body span.object_action")
      .text($(e.relatedTarget).attr("data-object-action"));
    $(this)
      .find(".modal-body input.confirm_object_name")
      .attr("placeholder", $(e.relatedTarget).attr("data-object-type"));

    /* set data-form for modal to correct form */
    $("#modal_confirm_remove").data("form", $(e.relatedTarget).closest("form"));
  });

  /* enable the remove button if the input field matches the object name */
  $(document).on(
    "keyup",
    "#action_modal input.confirm_object_name",
    function (e) {
      if (
        $(this).parent().siblings("p").children("strong.object_name").text() ==
        $(this).val()
      ) {
        $("#modal_confirm_remove").attr("disabled", false);

        if (e.keyCode == 13) {
          // simulate clicking the button if they press enter
          $("#modal_confirm_remove").click();
        }
      } else {
        $("#modal_confirm_remove").attr("disabled", true);
      }
    },
  );

  $(document).on("hidden.bs.modal", "#action_modal", function () {
    $(this).find("input.confirm_object_name").val("");
    $("#modal_confirm_remove").attr("disabled", true);
  });

  /* submit deletion of specific object */
  $(document).on("click", "#modal_confirm_remove", function () {
    // all checked checkbox type inputs within a delete_vendor_patient_form class
    // collect ids
    var checked = $(".delete_vendor_patients_form input:checkbox:checked");
    if (checked.length > 0) {
      var ids = $.map(checked, function (val, i) {
        return $(val).attr("id");
      });
      var input = $("<input>")
        .attr("type", "hidden")
        .attr("name", "patient_ids")
        .val(ids);
      $(this).data("form").append(input);
    }
    $(this).data("form").submit();
  });
}

export function initializeAdmin() {
  var assignmentIndex = 1000;
  var addAssignment = function (e) {
    assignmentIndex++;
    e.preventDefault();
    var vendor = $("#vendor_select")[0].selectedOptions[0];
    var role = $("#role_select")[0].selectedOptions[0];
    //does the assignment already exist"
    //should this be done for a user that has a role other then user (atl,admin this means nothing as they alreay have those permissions)
    if (
      $("input[value='" + vendor.value + "'][name*='[vendor_id]']").length == 0
    ) {
      var tr = $("<tr>");
      tr.append($("<td>" + role.text + "</td>"));
      tr.append($("<td>" + vendor.text + "</td>"));
      var buttonTd = $("<td>");
      tr.append(buttonTd);
      buttonTd.append(
        $(
          "<input type='hidden' name='assignments[" +
            assignmentIndex +
            "][vendor_id]' value='" +
            vendor.value +
            "'/>",
        ),
      );
      buttonTd.append(
        $(
          "<input type='hidden' name='assignments[" +
            assignmentIndex +
            "][role]' value='" +
            role.value +
            "'/>",
        ),
      );
      buttonTd.append(
        $(
          "<button onclick='$(this).parent().parent().remove()' > Remove </button>",
        ),
      );
      $("#assignments").append(tr);
    }
  };
  $("#addAssignment").click(addAssignment);

  $(".settings-tabs").tabs();
  $(".settings-tabs > ul > li").removeClass("ui-corner-top");

  var $customModeButtons = $("input[name='mode']");

  $customModeButtons.on("change", function () {
    if ($customModeButtons.filter(":checked").val() == "custom") {
      $("#settings-custom").show();
    } else {
      $("#settings-custom").hide();
    }
  });

  $customModeButtons.trigger("change");

  $(".activity-paginate").click(function () {
    window.Turbolinks?.ProgressBar?.start?.()
    window.Turbolinks?.ProgressBar?.advanceTo?.(25)
  });
}

function hideModalById(id) {
  const el = document.getElementById(id)
  if (!el) return
  if (!window.bootstrap?.Modal) return

  const modal =
    window.bootstrap.Modal.getInstance(el) || new window.bootstrap.Modal(el)
  modal.hide()
}

export function initializeChecklistTest() {
  // Enable changing measures
  $("#save_options")
    .find("button")
    .on("click", function (event) {
      event.preventDefault();
      $(".btn-danger").attr("disabled", false);
    });

  // For each criteria, lookup if its a negated code or vs, to set toggle lable
  var li = document.getElementsByClassName("data-criteria");
  for (var i = 0; i < li.length; i++) {
    lookupLabelFunction(i);
  }
  $(document).on("click", "#modify_record", function (event) {
    event.preventDefault();
    $(".hide-me").hide();
    $(".show-me").show();
  });

  $(document).on("click", "button.modal-btn", function (event) {
    event.preventDefault();
    var currentTarget = event.currentTarget;
    var index_value = $(currentTarget).data("index-value");
    var attribute_value = $(currentTarget).data("attribute-value");
    var code_string = $(currentTarget).data("code-string");

    if (attribute_value == false) {
      const input_box_type = "code";
      document.getElementById(
        "product_test_checked_criteria_attributes_" + index_value + "_" + input_box_type
      ).value = code_string;

      hideModalById("lookupModal" + index_value);
    }

    if (attribute_value == true) {
      const input_box_type = "attribute_code";
      document.getElementById(
        "product_test_checked_criteria_attributes_" + index_value + "_" + input_box_type
      ).value = code_string;

      hideModalById("lookupModal-negation" + index_value);
      hideModalById("lookupModal-fieldvalues" + index_value);
      hideModalById("lookupModal-result" + index_value);
    }
  });
}

export function lookupFunction(index, is_att) {
  // Declare variables
  var input, filter, ul, li, a, i;
  input = document.getElementById("lookupFilter" + index + is_att);
  filter = input.value.toUpperCase();
  ul = document.getElementById("lookup_codes" + index + is_att);
  li = ul.getElementsByTagName("li");

  // Loop through all list items, and hide those who don't match the search query
  for (i = 0; i < li.length; i++) {
    a = li[i].getElementsByTagName("i")[0];
    if (a.innerHTML.toUpperCase().indexOf(filter) > -1) {
      li[i].style.display = "";
    } else {
      li[i].style.display = "none";
    }
  }
}

export function initializeInfiniteScroll() {
  viewMore = $("#view-more");

  // Call checkAndLoad now and when the page scrolls
  checkAndLoad();
  $(window).on("scroll", checkAndLoad);

  viewMore
    .find("a")
    .unbind("click")
    .click(function (e) {
      nextPage();
      return e.preventDefault();
    });
}

export function initializeRecord() {
  // Bundle selection handlers (idempotent)
  $(document)
    .off("change.cypressBundle", 'input[name="bundle_id"]')
    .on("click.cypressBundle", 'input[name="bundle_id"]', function () {
      const bundle_id = $(this).val()

      // ensure UI state updates immediately
      this.checked = true

      let url = null
      if ($(this).next(".bundle-checkbox").length > 0) {
        url = `/bundles/${bundle_id}/records`
      } else if ($(this).next(".vendor-checkbox").length > 0) {
        url = `?bundle_id=${bundle_id}`
      }
      if (!url) return

      // let the browser paint the checked state, then navigate
      requestAnimationFrame(() => window.Turbo?.visit?.(url))
    })

  // Danger panel checkbox changes (idempotent)
  $(document)
    .off("change.cypressVendorPatients", ".delete_vendor_patients_form input:checkbox")
    .on("change.cypressVendorPatients", ".delete_vendor_patients_form input:checkbox", changePanel)

  // Select-all button (idempotent)
  $(document)
    .off("click.cypressVendorSelectAll", "#vendor-patient-select-all")
    .on("click.cypressVendorSelectAll", "#vendor-patient-select-all", function () {
      const button_font = $(this).find("i")
      const checkbox = $(".delete_vendor_patients_form input:checkbox")

      if ($(this).val() == "unchecked") {
        checkbox.prop("checked", true)
        button_font.removeClass("fa-square").addClass("fa-check-square")
        $(this).prop("title", "Unselect All")
        $("#vendor-patient-select-all-text").text("Unselect All")
        $(this).val("checked")
      } else {
        checkbox.prop("checked", false)
        button_font.removeClass("fa-check-square").addClass("fa-square")
        $(this).prop("title", "Select All")
        $("#vendor-patient-select-all-text").text("Select All")
        $(this).val("unchecked")
      }

      changePanel()
    })
}

export function teardown() {
  // remove delegated event handlers bound on document
  $(document).off(".cypressBundle")
  $(document).off(".cypressVendorPatients")
  $(document).off(".cypressVendorSelectAll")

  // or, equivalently, in one line:
  // $(document).off(".cypressBundle .cypressVendorPatients .cypressVendorSelectAll")
}