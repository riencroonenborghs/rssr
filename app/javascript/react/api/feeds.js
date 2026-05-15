import { api } from "./client"

export function fetchFeeds() {
  return api.get("/feeds")
}

export function fetchFeed(id, page = 1) {
  return api.get(`/feeds/${id}?page=${page}`)
}
