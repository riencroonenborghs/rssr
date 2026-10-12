import { useCallback, useEffect, useState } from "react"
import { apiRequest } from "./api"
import { useBookmarkChanges, withBookmark } from "./bookmarks"
import { useReadChanges, withRead } from "./useMarkRead"

// Loads entries from an endpoint returning { entries, next_page }, a page at a time, keeping their
// read and bookmarked state in sync. Without an apiPath nothing is loaded (e.g. before a search).
export default function useEntriesPages(apiPath) {
  const [entries, setEntries] = useState([])
  const [nextPage, setNextPage] = useState(null)
  const [loading, setLoading] = useState(Boolean(apiPath))
  const [error, setError] = useState(null)

  const load = useCallback(async (page, signal) => {
    setLoading(true)
    setError(null)
    try {
      const data = await apiRequest(`${apiPath}${apiPath.includes("?") ? "&" : "?"}page=${page}`, { signal })
      // Entries may shift between pages as new ones arrive; skip ones already listed.
      setEntries((current) => {
        const listed = new Set(current.map((entry) => entry.id))
        return [...current, ...data.entries.filter((entry) => !listed.has(entry.id))]
      })
      setNextPage(data.next_page)
      setLoading(false)
    } catch (loadError) {
      if (loadError.name === "AbortError") return
      setError(loadError)
      setLoading(false)
    }
  }, [apiPath])

  useEffect(() => {
    const controller = new AbortController()
    setEntries([])
    setNextPage(null)
    if (!apiPath) {
      setLoading(false)
      return
    }
    load(1, controller.signal)
    return () => controller.abort()
  }, [apiPath, load])

  useReadChanges(useCallback((read) => {
    setEntries((current) => current.map((entry) => withRead(entry, read)))
  }, []))

  useBookmarkChanges(useCallback((change) => {
    setEntries((current) => current.map((entry) => withBookmark(entry, change)))
  }, []))

  const loadMore = useCallback(() => load(nextPage), [load, nextPage])
  return { entries, nextPage, loading, error, loadMore }
}
