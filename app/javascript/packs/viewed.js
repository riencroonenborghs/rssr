$(function() {
  $("#admin #today .entry-wrapper").on("click", function(_event) {
    const entry = this;
    const id = entry.dataset.entryId;

    $.post(`/viewed/${id}`, function (_event, status) {
      if (status === "success") {
        entry.classList.add("viewed");
      }
    });
  });
});
