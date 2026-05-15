import { api } from "./client"

export function fetchBookmarks(page = 1) {
  return api.get(`/bookmarks?page=${page}`)
}
