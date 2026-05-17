import { api } from "./client"

export function fetchFeeds() {
  return api.get("/feeds")
}

export function fetchFeed(id, page = 1) {
  return api.get(`/feeds/${id}?page=${page}`)
}

export function fetchEntryUrl(feedId, entryId) {
  return `/v2/feeds/${feedId}/entries/${entryId}`
}

export function fetchEntry(feedId, entryId) {
  return api.get(`/feeds/${feedId}/entries/${entryId}`)
}
