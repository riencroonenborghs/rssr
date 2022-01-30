const handleViewed = function (entryId, entry) {
  $.post(`/viewed/${entryId}`, function (_event, status) {
    if (status === "success") {
      entry.classList.add("entries--viewed");
    }
  });
}

const handleModal = function (entryId) {
  const modal = $(`#modal-entry-${entryId}`);
  modal.addClass("is-active");
  modal.addClass("is-clipped");
  
  modal.find("button").on("click", function(e) {
    modal.removeClass("is-active");
    modal.removeClass("is-clipped");
    modal.off("click");
  });

  $(document).on("keydown", function (event) {
    const e = event || window.event;

    // Escape key
    if (e.keyCode === 27) {
      modal.removeClass("is-active");
      modal.removeClass("is-clipped");

      $(document).off("keydown");
    }
  });
}

const entryTitles = function() {
  $(".entries .entries--title").off("click");
  $(".entries .entries--title").on("click", function(e) {
    e.preventDefault();
    e.stopPropagation();
    
    const title = this;
    const entry = title.closest(".entry-wrapper");
    const entryId = entry.dataset.entryId;

    handleViewed(entryId, entry);
    if (title.classList.contains("summary")) {
      handleModal(entryId);
    }
  });
}

$(function() {
  entryTitles();

  $(document).ajaxSuccess( function(data) {
    entryTitles();
  });
});

