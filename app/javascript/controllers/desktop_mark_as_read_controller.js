import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  markAsRead (event) {
    const entry = event.target.closest('.entry')
    const entryId = entry.dataset.entryId

    let headers = {}
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content

    fetch(
      `/viewed/${entryId}`,
      {
        method: 'POST',
        headers: headers
      }
    ).then((result) => {
      if (result.status === 200) {
        entry.classList.add('bg-zinc-100')
        entry.classList.add('text-zinc-400')
      }
    })
  }
}
