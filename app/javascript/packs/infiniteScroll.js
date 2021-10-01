$(function() {
  let page = 1;
  let timeout;
  
  $(window).scroll(function () { 
    if ($(window).scrollTop() >= $(document).height() - $(window).height()) {      
      if (timeout) { clearTimeout(timeout); }
      timeout = setTimeout(function() {
        $(".page-loading").show();

        page += 1;
        const url = `${window.location.search.pathname || ''}?page=${page}`;

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
