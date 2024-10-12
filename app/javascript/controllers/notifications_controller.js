import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  ack (event) {
    const link = event.target.closest('.ack-notification')
    const linkUrl = link.dataset.ackUrl
    console.log(linkUrl)

    let headers = {}
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content

    fetch(
      linkUrl,
      {
        method: 'POST',
        headers: headers
      }
    ).then((result) => {
      if (result.status === 200) {
        const alert = link.closest(".alert")
        alert.classList.add("animate-ping")
        const hide = function () { alert.classList.add('hidden') }
        setTimeout(hide, 250)
      }
    })
  }
}
