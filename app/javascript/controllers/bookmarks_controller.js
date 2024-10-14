import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  add (event) {
    const link = event.target.closest("a")
    const url = link.href
    const bookmark = event.target.closest(".bookmark")
    link.classList.add("animate-ping")
    const bookmarked = bookmark.getElementsByClassName("bookmarked")[0]
    const notBookmarked = bookmark.getElementsByClassName("not-bookmarked")[0]

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
        bookmark.classList.add('text-zinc-300')
        bookmarked.classList.remove('hidden');
        notBookmarked.classList.add('hidden');
        link.classList.remove("animate-ping")
        bookmark.classList.remove('text-zinc-300');
      }
    })

    event.stopPropagation()
    event.preventDefault()
  }

  remove (event) {
    const link = event.target.closest("a")
    const url = link.href
    const bookmark = event.target.closest(".bookmark")
    link.classList.add("animate-ping")
    const bookmarked = bookmark.getElementsByClassName("bookmarked")[0]
    const notBookmarked = bookmark.getElementsByClassName("not-bookmarked")[0]

    let headers = {}
    headers['X-CSRF-Token'] = document.querySelector('meta[name="csrf-token"]').content

    fetch(
      url,
      {
        method: 'DELETE',
        headers: headers
      }
    ).then((result) => {
      if (result.status === 200) {        
        bookmark.classList.add('text-zinc-300')
        notBookmarked.classList.remove('hidden');
        bookmarked.classList.add('hidden');
        link.classList.remove("animate-ping")
        bookmark.classList.remove('text-zinc-300');
      }
    })

    event.stopPropagation()
    event.preventDefault()
  }
}
