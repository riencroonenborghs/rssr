import React, { useState, useEffect } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import { fetchUnread } from "./api/unread"

export default function App() {
  const [entries, setEntries] = useState([])
  const [loading, setLoading] = useState(true)
  const [activeNavItem, setActiveNavItem] = useState(null)
  const [activeEntry, setActiveEntry] = useState(null)

  useEffect(() => {
    setLoading(true)
    fetchUnread()
      .then((data) => setEntries(data.entries || []))
      .finally(() => setLoading(false))
  }, [])

  const feeds = Object.values(
    entries.reduce((acc, e) => {
      if (!acc[e.feed.id]) acc[e.feed.id] = { id: e.feed.id, title: e.feed.title, count: 0 }
      acc[e.feed.id].count++
      return acc
    }, {})
  )

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
