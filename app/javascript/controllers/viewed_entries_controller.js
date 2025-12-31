import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  markAsViewed (event) {
    const entry = event.target.closest('.entry')
    entry.classList.add('bg-gray-50')
  }
}
