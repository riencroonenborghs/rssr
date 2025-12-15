import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  markAsBookmarked (event) {
    const bookmarks = event.target.closest('.bookmarks')
    const notBookmarked = bookmarks.querySelector('.not-bookmarked')
    const bookmarked = bookmarks.querySelector('.bookmarked')
    notBookmarked.classList.remove('hidden')
    bookmarked.classList.add('hidden')
  }

  markAsNotBookmarked (event) {
    const bookmarks = event.target.closest('.bookmarks')
    const notBookmarked = bookmarks.querySelector('.not-bookmarked')
    const bookmarked = bookmarks.querySelector('.bookmarked')
    notBookmarked.classList.add('hidden')
    bookmarked.classList.remove('hidden')
  }
}
