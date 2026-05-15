import React, { useState, useEffect, useCallback } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import MobileNav from "./mobile/MobileNav"
import MobileEntriesList from "./mobile/MobileEntriesList"
import MobileEntryDetail from "./mobile/MobileEntryDetail"
import { fetchUnread } from "./api/unread"
import { fetchFeeds, fetchFeed, fetchEntry } from "./api/feeds"
import { fetchTag } from "./api/tags"
import { fetchBookmarks } from "./api/bookmarks"
import { pushUrl, parseUrl } from "./hooks/useAppNavigation"
import { useIsMobile } from "./hooks/useIsMobile"

export default function App() {
  const isMobile = useIsMobile()

  const [feeds, setFeeds] = useState([])
  const [entries, setEntries] = useState([])
  const [meta, setMeta] = useState(null)
  const [loadingMore, setLoadingMore] = useState(false)
  const [unreadCount, setUnreadCount] = useState(null)
  const [bookmarkCount, setBookmarkCount] = useState(null)
  const [loading, setLoading] = useState(true)
  const [activeNavItem, setActiveNavItem] = useState(null)
  const [activeEntry, setActiveEntry] = useState(null)
  const [entryLoading, setEntryLoading] = useState(false)
  const [mobileView, setMobileView] = useState("nav")

  function setEntriesFromResponse(data) {
    setEntries(data.entries || [])
    setMeta(data.meta || null)
  }

  function appendEntriesFromResponse(data) {
    setEntries((prev) => [...prev, ...(data.entries || [])])
    setMeta(data.meta || null)
  }

  useEffect(() => {
    const { feedId, entryId, tagId, view } = parseUrl()

    setLoading(true)
    Promise.all([fetchFeeds(), fetchUnread(), fetchBookmarks()])
      .then(([feedsData, unreadData, bookmarksData]) => {
        setFeeds(feedsData.feeds || [])
        setUnreadCount(unreadData.meta?.total_count ?? null)
        setBookmarkCount(bookmarksData.meta?.total_count ?? null)

        if (tagId) {
          setActiveNavItem({ type: "tag", id: tagId })
          setMobileView("list")
          return fetchTag(tagId).then((data) => setEntriesFromResponse(data))
        } else if (view === "bookmarks") {
          setActiveNavItem({ type: "bookmarks" })
          setEntriesFromResponse(bookmarksData)
          setMobileView("list")
        } else if (feedId) {
          return fetchFeed(feedId).then((data) => {
            setEntriesFromResponse(data)
            const feed = (feedsData.feeds || []).find((f) => String(f.id) === feedId)
            setActiveNavItem({ type: "feed", id: Number(feedId), title: feed?.title || data.feed?.title })
            setMobileView("list")
            if (entryId) {
              setEntryLoading(true)
              setMobileView("entry")
              return fetchEntry(feedId, entryId)
                .then((ed) => setActiveEntry({ ...ed.entry, feed: ed.feed }))
                .finally(() => setEntryLoading(false))
            }
          })
        } else {
          setEntriesFromResponse(unreadData)
          setMobileView("nav")
        }
      })
      .finally(() => setLoading(false))
  }, [])

  function handleNavSelect(item) {
    setActiveEntry(null)
    setActiveNavItem(item)
    setLoading(true)
    setMeta(null)
    setMobileView("list")
    pushUrl(item, null)

    if (item.type === "feed") {
      fetchFeed(item.id)
        .then((data) => setEntriesFromResponse(data))
        .finally(() => setLoading(false))
    } else if (item.type === "bookmarks") {
      fetchBookmarks()
        .then((data) => setEntriesFromResponse(data))
        .finally(() => setLoading(false))
    } else {
      fetchUnread()
        .then((data) => {
          setEntriesFromResponse(data)
          setUnreadCount(data.meta?.total_count ?? null)
        })
        .finally(() => setLoading(false))
    }
  }

  const handleLoadMore = useCallback(() => {
    if (!meta || meta.current_page >= meta.total_pages || loadingMore) return
    const nextPage = meta.current_page + 1
    setLoadingMore(true)

    const item = activeNavItem
    let request
    if (item?.type === "feed") {
      request = fetchFeed(item.id, nextPage)
    } else if (item?.type === "bookmarks") {
      request = fetchBookmarks(nextPage)
    } else if (item?.type === "tag") {
      request = fetchTag(item.id, nextPage)
    } else {
      request = fetchUnread(nextPage)
    }

    request
      .then((data) => appendEntriesFromResponse(data))
      .finally(() => setLoadingMore(false))
  }, [meta, loadingMore, activeNavItem])

  function handleEntrySelect(entry) {
    setActiveEntry(null)
    setEntryLoading(true)
    setEntries((prev) => prev.map((e) => e.id === entry.id ? { ...e, viewed: true } : e))
    setMobileView("entry")
    pushUrl(activeNavItem, entry)
    fetchEntry(entry.feed.id, entry.id)
      .then((data) => setActiveEntry({ ...data.entry, feed: data.feed }))
      .finally(() => setEntryLoading(false))
  }

  function handleTagSelect(tag) {
    setActiveEntry(null)
    setActiveNavItem({ type: "tag", ...tag })
    setLoading(true)
    setMeta(null)
    setMobileView("list")
    pushUrl({ type: "tag", ...tag }, null)
    fetchTag(tag.id)
      .then((data) => setEntriesFromResponse(data))
      .finally(() => setLoading(false))
  }

  const listTitle = {
    feed: activeNavItem?.title,
    tag: `#${activeNavItem?.name}`,
    bookmarks: "Bookmarks",
  }[activeNavItem?.type] ?? "Unread"

  const hasMore = meta ? meta.current_page < meta.total_pages : false

  if (isMobile) {
    if (mobileView === "entry") {
      return (
        <MobileEntryDetail
          entry={activeEntry}
          loading={entryLoading}
          onBack={() => setMobileView("list")}
        />
      )
    }
    if (mobileView === "list") {
      return (
        <MobileEntriesList
          title={listTitle}
          entries={entries}
          loading={loading}
          loadingMore={loadingMore}
          hasMore={hasMore}
          onLoadMore={handleLoadMore}
          onSelect={handleEntrySelect}
          onFeedSelect={(feed) => handleNavSelect({ type: "feed", ...feed })}
          onTagSelect={handleTagSelect}
          onBack={() => setMobileView("nav")}
        />
      )
    }
    return (
      <MobileNav
        feeds={feeds}
        unreadCount={unreadCount}
        bookmarkCount={bookmarkCount}
        activeItem={activeNavItem}
        onSelect={handleNavSelect}
      />
    )
  }

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
        loadingMore={loadingMore}
        hasMore={hasMore}
        onLoadMore={handleLoadMore}
        activeEntry={activeEntry}
        onSelect={handleEntrySelect}
        onFeedSelect={(feed) => handleNavSelect({ type: "feed", ...feed })}
        onTagSelect={handleTagSelect}
      />
      <EntryDetail entry={activeEntry} loading={entryLoading} />
    </div>
  )
}
