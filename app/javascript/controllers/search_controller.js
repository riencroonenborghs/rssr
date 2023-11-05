import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  add (event) {
    let template = document.querySelector('#template')
    let row = template.querySelector('.search-row')
    let clone = row.cloneNode(true)
    clone.classList.remove('hidden')
    document.querySelector('#search').appendChild(clone)

    event.stopPropagation()
    event.preventDefault()
  }

  remove (event) {
    let row = event.target.closest('.search-row')
    document.querySelector('#search').removeChild(row)
    event.stopPropagation()
    event.preventDefault()
  }
}
