import React, { useState, useEffect } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import { fetchUnread } from "./api/unread"
import { fetchFeeds, fetchFeed, fetchEntry } from "./api/feeds"
import { fetchTag } from "./api/tags"
import { fetchBookmarks } from "./api/bookmarks"

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
    setLoading(true)
    Promise.all([fetchFeeds(), fetchUnread(), fetchBookmarks()])
      .then(([feedsData, unreadData, bookmarksData]) => {
        setFeeds(feedsData.feeds)
        setEntries(unreadData.entries || [])
        setUnreadCount(unreadData.meta?.total_count ?? null)
        setBookmarkCount(bookmarksData.meta?.total_count ?? null)
      })
      .finally(() => setLoading(false))
  }, [])

  function handleNavSelect(item) {
    setActiveEntry(null)
    setActiveNavItem(item)
    setLoading(true)

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
    fetchEntry(entry.feed.id, entry.id)
      .then((data) => setActiveEntry({ ...data.entry, feed: data.feed }))
      .finally(() => setEntryLoading(false))
  }

  function handleTagSelect(tag) {
    setActiveEntry(null)
    setActiveNavItem({ type: "tag", ...tag })
    setLoading(true)
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
