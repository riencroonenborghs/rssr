import React, { useState, useEffect, useCallback } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import DailyReportDetail from "./components/DailyReportDetail"
import DailyReportsList from "./components/DailyReportsList"
import MobileNav from "./mobile/MobileNav"
import MobileEntriesList from "./mobile/MobileEntriesList"
import MobileEntryDetail from "./mobile/MobileEntryDetail"
import { fetchUnread } from "./api/unread"
import { fetchFeeds, fetchFeed, fetchEntry, fetchEntryUrl } from "./api/feeds"
import { fetchTag } from "./api/tags"
import { fetchBookmarks } from "./api/bookmarks"
import { fetchDailyReport, fetchDailyReports } from "./api/reports"
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
  const [activeDailyReport, setActiveDailyReport] = useState(null)
  const [dailyReportLoading, setDailyReportLoading] = useState(false)
  const [dailyReports, setDailyReports] = useState([])
  const [dailyReportsLoading, setDailyReportsLoading] = useState(false)
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
    const { feedId, entryId, tagId, view, reportId, dailyId } = parseUrl()

    setLoading(true)
    Promise.all([fetchFeeds(), fetchUnread(), fetchBookmarks()])
      .then(([feedsData, unreadData, bookmarksData]) => {
        setFeeds(feedsData.feeds || [])
        setUnreadCount(unreadData.meta?.total_count ?? null)
        setBookmarkCount(bookmarksData.meta?.total_count ?? null)

        if (reportId && dailyId) {
          setActiveNavItem({ type: "daily_report", id: Number(dailyId), reportId: Number(reportId) })
          setDailyReportLoading(true)
          return fetchDailyReport(reportId, dailyId)
            .then((data) => setActiveDailyReport(data.report))
            .finally(() => setDailyReportLoading(false))
        } else if (reportId) {
          setActiveNavItem({ type: "report", id: Number(reportId) })
          setDailyReportsLoading(true)
          return fetchDailyReports(reportId)
            .then((data) => setDailyReports(data.reports || []))
            .finally(() => setDailyReportsLoading(false))
        } else if (tagId) {
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
    if (item.type === "daily_report") return handleDailyReportSelect(item)
    if (item.type === "report") return handleReportSelect(item)
    setActiveEntry(null)
    setActiveDailyReport(null)
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

  function handleReportSelect(item) {
    setActiveEntry(null)
    setActiveDailyReport(null)
    setActiveNavItem(item)
    setDailyReports([])
    setDailyReportsLoading(true)
    pushUrl(item, null)
    fetchDailyReports(item.id)
      .then((data) => setDailyReports(data.reports || []))
      .finally(() => setDailyReportsLoading(false))
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

  function handleMobileEntrySelect(entry) {
    setEntries((prev) => prev.map((e) => e.id === entry.id ? { ...e, viewed: true } : e))
    window.open(fetchEntryUrl(entry.feed.id, entry.id), '_blank').focus()
  }

  function handleDailyReportSelect(item) {
    setActiveDailyReport(null)
    setDailyReportLoading(true)
    // Keep activeNavItem as "report" when selecting from DailyReportsList middle pane
    if (activeNavItem?.type !== "report") {
      setActiveNavItem(item)
    }
    pushUrl(item, null)
    fetchDailyReport(item.reportId, item.id)
      .then((data) => setActiveDailyReport(data.report))
      .finally(() => setDailyReportLoading(false))
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
          onSelect={handleMobileEntrySelect}
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

  const showDailyReportsList = activeNavItem?.type === "report"
  const showDailyReportDetail = activeNavItem?.type === "daily_report" || (showDailyReportsList && activeDailyReport != null)

  return (
    <div className="flex flex-row h-screen overflow-hidden">
      <Sidebar
        feeds={feeds}
        unreadCount={unreadCount}
        bookmarkCount={bookmarkCount}
        activeItem={activeNavItem}
        onSelect={handleNavSelect}
      />
      {showDailyReportsList
        ? <DailyReportsList
            title={activeNavItem?.title}
            dailyReports={dailyReports}
            loading={dailyReportsLoading}
            activeEntry={activeDailyReport}
            onSelect={handleDailyReportSelect}
          />
        : <EntriesList
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
      }
      {showDailyReportDetail
        ? <DailyReportDetail report={activeDailyReport} loading={dailyReportLoading} />
        : <EntryDetail entry={activeEntry} loading={entryLoading} />
      }
    </div>
  )
}
