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