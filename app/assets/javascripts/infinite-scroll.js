$(function() {
  var approachingBottomOfPage, loadNextPageAt, nextPage, nextPageFnRunning, viewMore;

  viewMore = $('#view-more');
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

  $(window).on('load scroll', function() {
    if (approachingBottomOfPage()) {
      return nextPage();
    }
  });

  viewMore.find('a').unbind('click').click(function(e) {
    nextPage();
    return e.preventDefault();
  });
});