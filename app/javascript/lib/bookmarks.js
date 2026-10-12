import { apiRequest } from "./api"
import { publish, useEntryEvent } from "./entryEvents"

// Saves an entry's bookmark and announces the change, so every list and detail view showing the
// entry can update, in any tab.
export async function setBookmarked(entryId, bookmarked) {
  await apiRequest(`/api/entries/${entryId}/bookmark`, { method: bookmarked ? "POST" : "DELETE" })
  publish("bookmark", { id: entryId, bookmarked })
}

// Calls onChange({ id, bookmarked }) whenever an entry's bookmark changes.
export const useBookmarkChanges = (onChange) => useEntryEvent("bookmark", onChange)

// Applies a bookmark change to an entry, leaving other entries as they are.
export const withBookmark = (entry, { id, bookmarked }) => (entry?.id === id ? { ...entry, bookmarked } : entry)
