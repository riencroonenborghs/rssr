import { useCallback, useRef } from "react"
import { apiRequest } from "./api"
import { publish, useEntryEvent } from "./entryEvents"

// Returns markRead(entry), which marks an unread entry read once (effects may run twice in
// development) and announces it to every view, in any tab. Signed out, there is nobody to mark
// it read for.
export default function useMarkRead(session) {
  const marked = useRef(new Set())

  return useCallback(async (entry) => {
    if (!session.signedIn || entry.read || marked.current.has(entry.id)) return
    marked.current.add(entry.id)

    await apiRequest(`/api/entries/${entry.id}/read`, { method: "POST" })
    publish("read", { id: entry.id, feedId: entry.feed.id })
  }, [session.signedIn])
}

// Calls onRead({ id, feedId }) whenever an entry is marked read.
export const useReadChanges = (onRead) => useEntryEvent("read", onRead)

// Marks the entry with the given id as read, leaving other entries as they are.
export const withRead = (entry, { id }) => (entry?.id === id ? { ...entry, read: true } : entry)
