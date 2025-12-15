import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  show (event) {
    const mobile = event.target.closest(".mobile");
    mobile.querySelector("#menu").classList.remove("hidden");
    event.preventDefault();
    event.stopPropagation();
  }

  hide (event) {
    const mobile = event.target.closest(".mobile");
    mobile.querySelector("#menu").classList.add("hidden");
    event.preventDefault();
    event.stopPropagation();
  }
}
