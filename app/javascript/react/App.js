import React, { useState, useEffect } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import { fetchUnread } from "./api/unread"
import { fetchFeeds, fetchFeed, fetchEntry } from "./api/feeds"
import { fetchTag } from "./api/tags"
import { fetchBookmarks } from "./api/bookmarks"
import { pushUrl, parseUrl } from "./hooks/useAppNavigation"

export default function App() {
  const [feeds, setFeeds] = useState([])
  const [entries, setEntries] = useState([])
  const [unreadCount, setUnreadCount] = useState(null)
  const [bookmarkCount, setBookmarkCount] = useState(null)
  const [loading, setLoading] = useState(true)
  const [activeNavItem, setActiveNavItem] = useState(null)
  const [activeEntry, setActiveEntry] = useState(null)
  const [entryLoading, setEntryLoading] = useState(false)

  useEffect(() => {
    const { feedId, entryId, tagId, view } = parseUrl()

    const baseRequests = [fetchFeeds(), fetchUnread(), fetchBookmarks()]

    setLoading(true)
    Promise.all(baseRequests)
      .then(([feedsData, unreadData, bookmarksData]) => {
        setFeeds(feedsData.feeds || [])
        setUnreadCount(unreadData.meta?.total_count ?? null)
        setBookmarkCount(bookmarksData.meta?.total_count ?? null)

        if (tagId) {
          setActiveNavItem({ type: "tag", id: tagId })
          return fetchTag(tagId).then((data) => setEntries(data.entries || []))
        } else if (view === "bookmarks") {
          setActiveNavItem({ type: "bookmarks" })
          setEntries(bookmarksData.entries || [])
        } else if (feedId) {
          return fetchFeed(feedId).then((data) => {
            setEntries(data.entries || [])
            const feed = (feedsData.feeds || []).find((f) => String(f.id) === feedId)
            setActiveNavItem({ type: "feed", id: Number(feedId), title: feed?.title || data.feed?.title })
            if (entryId) {
              setEntryLoading(true)
              return fetchEntry(feedId, entryId)
                .then((ed) => setActiveEntry({ ...ed.entry, feed: ed.feed }))
                .finally(() => setEntryLoading(false))
            }
          })
        } else {
          setEntries(unreadData.entries || [])
        }
      })
      .finally(() => setLoading(false))
  }, [])

  function handleNavSelect(item) {
    setActiveEntry(null)
    setActiveNavItem(item)
    setLoading(true)
    pushUrl(item, null)

    if (item.type === "feed") {
      fetchFeed(item.id)
        .then((data) => setEntries(data.entries || []))
        .finally(() => setLoading(false))
    } else if (item.type === "bookmarks") {
      fetchBookmarks()
        .then((data) => setEntries(data.entries || []))
        .finally(() => setLoading(false))
    } else {
      fetchUnread()
        .then((data) => {
          setEntries(data.entries || [])
          setUnreadCount(data.meta?.total_count ?? null)
        })
        .finally(() => setLoading(false))
    }
  }

  function handleEntrySelect(entry) {
    setActiveEntry(null)
    setEntryLoading(true)
    setEntries((prev) => prev.map((e) => e.id === entry.id ? { ...e, viewed: true } : e))
    pushUrl(activeNavItem, entry)
    fetchEntry(entry.feed.id, entry.id)
      .then((data) => setActiveEntry({ ...data.entry, feed: data.feed }))
      .finally(() => setEntryLoading(false))
  }

  function handleTagSelect(tag) {
    setActiveEntry(null)
    setActiveNavItem({ type: "tag", ...tag })
    setLoading(true)
    pushUrl({ type: "tag", ...tag }, null)
    fetchTag(tag.id)
      .then((data) => setEntries(data.entries || []))
      .finally(() => setLoading(false))
  }

  const listTitle = {
    feed: activeNavItem?.title,
    tag: `#${activeNavItem?.name}`,
    bookmarks: "Bookmarks",
  }[activeNavItem?.type] ?? "Unread"

  return (
    <div className="flex flex-row h-screen overflow-hidden">
      <Sidebar
        feeds={feeds}
        unreadCount={unreadCount}
        bookmarkCount={bookmarkCount}
        activeItem={activeNavItem}
        onSelect={handleNavSelect}
      />
      <EntriesList
        title={listTitle}
        entries={entries}
        loading={loading}
        activeEntry={activeEntry}
        onSelect={handleEntrySelect}
        onFeedSelect={(feed) => handleNavSelect({ type: "feed", ...feed })}
        onTagSelect={handleTagSelect}
      />
      <EntryDetail entry={activeEntry} loading={entryLoading} />
    </div>
  )
}
