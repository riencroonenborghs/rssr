import React, { useState, useEffect } from "react"
import Sidebar from "./components/Sidebar"
import EntriesList from "./components/EntriesList"
import EntryDetail from "./components/EntryDetail"
import { fetchUnread } from "./api/unread"
import { fetchFeeds, fetchFeed } from "./api/feeds"
import { fetchTag } from "./api/tags"

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
        setFeeds(feedsData.feeds)
        setEntries(unreadEntries)
      })
      .finally(() => setLoading(false))
  }, [])

  function handleNavSelect(item) {
    setActiveEntry(null)
    setActiveNavItem(item)

    if (item.type === "feed") {
      setLoading(true)
      fetchFeed(item.id)
        .then((data) => setEntries(data.entries || []))
        .finally(() => setLoading(false))
    } else {
      setLoading(true)
      fetchUnread()
        .then((data) => setEntries(data.entries || []))
        .finally(() => setLoading(false))
    }
  }

  function handleTagSelect(tag) {
    setActiveEntry(null)
    setActiveNavItem({ type: "tag", ...tag })
    setLoading(true)
    fetchTag(tag.id)
      .then((data) => setEntries(data.entries || []))
      .finally(() => setLoading(false))
  }

  const listTitle = activeNavItem?.type === "feed"
    ? activeNavItem.title
    : activeNavItem?.type === "tag"
      ? `#${activeNavItem.name}`
      : "Unread"

  return (
    <div className="flex flex-row h-screen overflow-hidden">
      <Sidebar
        feeds={feeds}
        activeItem={activeNavItem}
        onSelect={handleNavSelect}
      />
      <EntriesList
        title={listTitle}
        entries={entries}
        loading={loading}
        activeEntry={activeEntry}
        onSelect={setActiveEntry}
        onFeedSelect={(feed) => handleNavSelect({ type: "feed", ...feed })}
        onTagSelect={handleTagSelect}
      />
      <EntryDetail entry={activeEntry} />
    </div>
  )
}
