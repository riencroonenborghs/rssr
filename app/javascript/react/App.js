import React, { useState, useEffect } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import { fetchUnread } from "./api/unread"
import { fetchFeeds } from "./api/feeds"

export default function App() {
  const [feeds, setFeeds] = useState([])
  const [entries, setEntries] = useState([])
  const [loading, setLoading] = useState(true)
  const [activeNavItem, setActiveNavItem] = useState(null)
  const [activeEntry, setActiveEntry] = useState(null)

  useEffect(() => {
    setLoading(true)
    Promise.all([fetchFeeds(), fetchUnread()])
      .then(([feedsData, unreadData]) => {
        const unreadEntries = unreadData.entries || []
        const countByFeedId = unreadEntries.reduce((acc, e) => {
          acc[e.feed.id] = (acc[e.feed.id] || 0) + 1
          return acc
        }, {})
        setFeeds((feedsData.feeds || []).map((f) => ({ ...f, count: countByFeedId[f.id] || 0 })))
        setEntries(unreadEntries)
      })
      .finally(() => setLoading(false))
  }, [])

  const visibleEntries = activeNavItem?.type === "feed"
    ? entries.filter((e) => e.feed.id === activeNavItem.id)
    : entries

  const listTitle = activeNavItem?.type === "feed" ? activeNavItem.title : "Unread"

  return (
    <div className="flex flex-row h-screen overflow-hidden">
      <Sidebar
        feeds={feeds}
        activeItem={activeNavItem}
        onSelect={(item) => { setActiveNavItem(item); setActiveEntry(null) }}
      />
      <EntriesList
        title={listTitle}
        entries={visibleEntries}
        loading={loading}
        activeEntry={activeEntry}
        onSelect={setActiveEntry}
      />
      <EntryDetail entry={activeEntry} />
    </div>
  )
}
