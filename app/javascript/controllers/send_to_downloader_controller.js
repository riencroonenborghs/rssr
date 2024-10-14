import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  send (event) {
    const link = event.target.closest("a")
    const url = link.href
    const entry = link.closest(".entry")
    
    let headers = {}
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content

    fetch(
      url,
      {
        method: 'POST',
        headers: headers
      }
    ).then((result) => {
      if (result.status === 200) {
        entry.classList.add('bg-sky-50')
        entry.classList.add('text-amber-400')
      }
    })

    event.stopPropagation()
    event.preventDefault()
  }
}
