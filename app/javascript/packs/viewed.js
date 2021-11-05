$(function() {
  $("#admin #today .entry-wrapper .title").on("click", function(_event, a) {
    const title = this;
    const entry = title.closest(".entry-wrapper");
    const id = entry.dataset.entryId;

    $.post(`/viewed/${id}`, function (_event, status) {
      if (status === "success") {
        entry.classList.add("viewed");
      }
    });
  });
});
