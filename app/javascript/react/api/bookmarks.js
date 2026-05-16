import { api } from "./client"

export function fetchBookmarks(page = 1) { return api.get(`/bookmarks?page=${page}`) }
export function createBookmark(entryId) { return api.post("/bookmarks", { entry_id: entryId }) }
export function deleteBookmark(entryId) { return api.delete(`/bookmarks/${entryId}`) }

