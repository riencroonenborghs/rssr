const handleViewed = function (entryId, entry) {
  $.post(`/viewed/${entryId}`, function (_event, status) {
    if (status === "success") {
      entry.classList.add("entries--viewed");
    }
  });
}

const entryTitles = function() {
  $(".entries .entries--title").off("click");

  $(".entries .entries--title").on("click", function(e) {
    const entry = this.closest(".entry-wrapper");
    const entryId = entry.dataset.entryId;
    handleViewed(entryId, entry);
  });
}

$(function() {
  entryTitles();

  $(document).ajaxSuccess( function(data) {
    entryTitles();
  });
});

