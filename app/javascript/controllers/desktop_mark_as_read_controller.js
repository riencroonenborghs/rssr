import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  markAsRead (event) {
    const entry = event.target.closest('.entry')
    entry.classList.add('bg-emerald-50')
    entry.classList.add('text-amber-400')
  }
}
