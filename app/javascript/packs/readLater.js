$(function() {
  const readLaterShowSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("spinner-grow")[0]
    spinner.classList.remove("d-none");
    link.classList.add("d-none");
  }

  const readLaterHideSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("spinner-grow")[0]
    spinner.classList.add("d-none");
    link.classList.remove("d-none");
  }

  const readLaterReadItShowSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("spinner-grow")[0]
    spinner.classList.remove("d-none");
    link.classList.add("d-none");
  }

  const readLaterReadItHideSpinner = function (link) {
    const wrapper = link.closest(".read-later-wrapper");
    const spinner = wrapper.getElementsByClassName("spinner-grow")[0]
    spinner.classList.add("d-none");
    link.classList.remove("d-none");
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
