$(function() {
  const readLaterShowSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("progress")[0]
    spinner.classList.remove("is-hidden");
    link.classList.add("is-hidden");
  }

  const readLaterHideSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("progress")[0]
    spinner.classList.add("is-hidden");
    link.classList.remove("is-hidden");
  }

  const readLaterReadItShowSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("progress")[0]
    spinner.classList.remove("is-hidden");
    link.classList.add("is-hidden");
  }

  const readLaterReadItHideSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("progress")[0]
    spinner.classList.add("is-hidden");
    link.classList.remove("is-hidden");
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
