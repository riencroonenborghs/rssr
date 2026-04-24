import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "arrow"]

  connect() {
    // Start closed by default
    this.open = false
  }

  toggle() {
    this.open = !this.open

    if (this.open) {
      this.listTarget.classList.remove("hidden")
      this.arrowTarget.style.transform = "rotate(0deg)"
    } else {
      this.listTarget.classList.add("hidden")
      this.arrowTarget.style.transform = "rotate(-90deg)"
    }
  }
}
