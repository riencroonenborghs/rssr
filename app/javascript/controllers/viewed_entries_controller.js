import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  markAsViewed (event) {
    const entry = event.target.closest('.entry .title')
    console.log(entry)
    entry.classList.add('line-through')
  }
}
