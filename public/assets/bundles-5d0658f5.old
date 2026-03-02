function elementContainsText(selector, text) {
    return $(selector).text().indexOf(text) > -1;
}

var updateBundleStatus = function() {
  if (elementContainsText('.tracker-status', 'queued') || elementContainsText('.tracker-status', 'working')) {
    $.ajax({url: window.location.pathname, type: "GET", dataType: 'script', data: { partial: 'bundle_list'}});
  }
}

$(document).on('page:change', updateBundleStatus);
