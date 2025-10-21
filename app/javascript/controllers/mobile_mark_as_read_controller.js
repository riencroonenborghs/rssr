import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  markAsRead (event) {
    const entry = event.target.closest('.entry')
    const logo = entry.querySelector('.entry--logo .entry--logo--logo')
    entry.classList.add('bg-zinc-100')
    entry.classList.add('text-zinc-400')

    if(logo !== null) {
      logo.classList.remove('bg-zinc-500')
      logo.classList.add('bg-zinc-400')
    }
  }
}
