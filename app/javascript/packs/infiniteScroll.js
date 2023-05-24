$(function() {
  let page = 1;
  let timeout;
  // calculate date in hex
  let offset = Math.round((new Date()).getTime() / 1000).toString(16);
  
  const loadMoreContent = function () {
    if (timeout) { clearTimeout(timeout); }
    timeout = setTimeout(function() {
      // $(".page-loading").show();

      // look up next page from offset onwards
      page += 1;
      const url = `${window.location.search.pathname || ''}?page=${page}&ts=${offset}`;

      $.get(url, function(data, status, xhr) {
        // $(".page-loading").hide();
        if (status == 'success') {
          // no more data? turn off scrolling
          if (data === "\n") { $(window).off("scroll"); }
          else {
            $(".entries").append(data);
          }
        }
      });
    }, 250);
  }

  const canScroll = $("body").hasClass("c_subscriptions") || $("body").hasClass("c_entries") || $("body").hasClass("c_feeds") || $("body").hasClass("c_watches") || $("body").hasClass("c_bookmarks");
  
  if (canScroll) {
    $('.entries').on("scroll", function () {
      if ($(window).scrollTop() >= $(document).height() - $(window).height() - 100) {
        if ($(".entries").length > 0) { // only entries are infinite scrollable
          loadMoreContent();
        }
      }
    });
  }
});
