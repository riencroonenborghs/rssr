import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  showClicked (event) {
    document.querySelector('#menu').classList.remove('hidden')

    event.preventDefault()
    event.stopPropagation()
  }

  hideClicked (event) {
    document.querySelector('#menu').classList.add('hidden')

    event.preventDefault()
    event.stopPropagation()
  }
}
