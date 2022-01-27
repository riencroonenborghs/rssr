const clickableModals = function() {
  $(".entries a.summary").off("click");
  $(".entries a.summary").on("click", function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const id = e.target.dataset.id;
    const modal = $(`#modal-entry-${id}`);
    
    modal.addClass("is-active");
    modal.addClass("is-clipped");
    
    modal.on("click", function(e) {
      modal.removeClass("is-active");
      modal.removeClass("is-clipped");
      modal.off("click");
    });

    $(document).on("keydown", function (event) {
      const e = event || window.event;
  
      if (e.keyCode === 27) { // Escape key
        modal.removeClass("is-active");
        modal.removeClass("is-clipped");
        $(document).off("keydown");
      }
    });
  });
}

$(function() {
  clickableModals();

  $(document).ajaxSuccess( function(data) {
    clickableModals();
  });
});

