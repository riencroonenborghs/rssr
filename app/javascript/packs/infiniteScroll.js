$(function() {
  let page = 1;
  let timeout;
  // calculate date in hex
  let offset = Math.round((new Date()).getTime() / 1000).toString(16);
  
  $(window).scroll(function () { 
    if ($(window).scrollTop() >= $(document).height() - $(window).height()) {      
      if (timeout) { clearTimeout(timeout); }
      timeout = setTimeout(function() {
        $(".page-loading").show();

        // look up next page from offset onwards
        page += 1;
        const url = `${window.location.search.pathname || ''}?page=${page}&ts=${offset}`;

        $.get(url, function(data, status) {
          $(".page-loading").hide();
          if (status == 'success') {
            $(".entries").append(data);            
          }          
        });
      }, 250);
    }
 });
});
