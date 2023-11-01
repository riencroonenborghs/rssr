import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  showClicked (event) {
    let menu = document.querySelector('#menu')
    menu.classList.remove('hidden')
    let parent = menu.parentNode
    parent.classList.add('bg-opacity-50')
    parent.classList.add('bg-gray-900')
    let nav = parent.querySelector('nav')
    nav.classList.add('bg-opacity-10')
    nav.classList.add('bg-gray-900')

    event.preventDefault()
    event.stopPropagation()
  }

  hideClicked (event) {
    let menu = document.querySelector('#menu')
    menu.classList.add('hidden')
    let parent = menu.parentNode
    parent.classList.remove('bg-opacity-50')
    parent.classList.remove('bg-gray-900')
    let nav = parent.querySelector('nav')
    nav.classList.remove('bg-opacity-10')
    nav.classList.remove('bg-gray-900')

    event.preventDefault()
    event.stopPropagation()
  }
}
