$(function() {
  const readLaterShowSpinner = function (link) {
    const icon = link.getElementsByClassName("far")[0];
    icon.classList.add("fa-spin");
  }

  const readLaterHideSpinner = function (link) {
    const icon = link.getElementsByClassName("far")[0];
    icon.classList.remove("fa-spin");
  }

  const readLaterReadItShowSpinner = function (link) {
    const icon = link.getElementsByClassName("fas")[0];
    icon.classList.add("fa-spin");
  }

  const readLaterReadItHideSpinner = function (link) {
    const icon = link.getElementsByClassName("fas")[0];
    icon.classList.remove("fa-spin");
  }

  document.body.addEventListener("ajax:before", (event) => {
    if (event.target.classList.contains("read-later-link")) {
      readLaterShowSpinner(event.target);
    } else if (event.target.classList.contains("read-later-read-it-link")) {
      readLaterReadItShowSpinner(event.target);
    }
  });

  document.body.addEventListener("ajax:success", (event) => {
    if (event.target.classList.contains("read-later-link")) {
      readLaterHideSpinner(event.target);
    } else if (event.target.classList.contains("read-later-read-it-link")) {
      readLaterReadItHideSpinner(event.target);
    }
  });
});
