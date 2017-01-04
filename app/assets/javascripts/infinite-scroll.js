var approachingBottomOfPage, loadNextPageAt, nextPage, nextPageFnRunning, viewMore, ready;

nextPageFnRunning = false;
loadNextPageAt = 3000;

approachingBottomOfPage = function() {
  return $(window).scrollTop() > $(document).height() - $(window).height() - loadNextPageAt;
};

nextPage = function() {
  var loadingMore, url;
  viewMore = $('#view-more');
  loadingMore = $('#loading-more');
  url = viewMore.find('a').attr('href');
  if (nextPageFnRunning || !url) {
    return;
  }
  viewMore.hide();
  loadingMore.show();
  nextPageFnRunning = true;
  return $.ajax({
    url: url,
    method: 'GET',
    dataType: 'script'
  }).always(function() {
    nextPageFnRunning = false;
    viewMore.show();
    return loadingMore.hide();
  });
};

// Checks to see if we are close to the bottom of the page and if we are load more measures
checkAndLoad = function() {
  if (approachingBottomOfPage()) {
    return nextPage();
  }
};

ready = function() {
  viewMore = $('#view-more');

  // Call checkAndLoad now and when the page scrolls
  checkAndLoad();
  $(window).on('scroll', checkAndLoad);

  viewMore.find('a').unbind('click').click(function(e) {
    nextPage();
    return e.preventDefault();
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
