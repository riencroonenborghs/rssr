import { Controller, del } from "@hotwired/stimulus"

export default class extends Controller {
  connect () {
    this.closed = true
    this.viewed = {}
  }

  showMenu (menu, parent, nav, entries) {
    menu.classList.remove('hidden')

    parent.classList.add('bg-opacity-50')
    parent.classList.add('bg-gray-900')

    nav.classList.add('bg-opacity-10')
    nav.classList.add('bg-gray-900')

    this.viewed = {}
    entries.forEach(entry => {
      entry.classList.remove("border-gray-50")
      entry.classList.add("border-gray-500")

      const entryId = entry.dataset.entryId
      this.viewed[entryId] = entry.classList.contains("bg-zinc-100")
      entry.classList.remove("bg-zinc-100")
      entry.classList.remove("text-zinc-400")
    });
  }

  hideMenu (menu, parent, nav, entries) {
    menu.classList.add('hidden')

    parent.classList.remove('bg-opacity-50')
    parent.classList.remove('bg-gray-900')

    nav.classList.remove('bg-opacity-10')
    nav.classList.remove('bg-gray-900')

    entries.forEach(entry => {
      entry.classList.add("border-gray-50")
      entry.classList.remove("border-gray-500")

      const entryId = entry.dataset.entryId
      if (this.viewed[entryId]) {
        entry.classList.add("bg-zinc-100")
        entry.classList.add("text-zinc-400")
      }
    });
  }

  toggleClicked (event) {
    let menu = document.querySelector('#menu')
    let parent = menu.parentNode
    let nav = parent.querySelector('nav')
    let entries = document.querySelectorAll('.entry')

    if (this.closed) { this.showMenu(menu, parent, nav, entries) }
    else { this.hideMenu(menu, parent, nav, entries) }
    this.closed = !this.closed

    event.preventDefault()
    event.stopPropagation()
  }
}
