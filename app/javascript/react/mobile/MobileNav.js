import React, { useState } from "react"
import FeedsDropdown from "../components/FeedsDropdown"
import SettingsModal from "../components/SettingsModal"

const userEmail = document.getElementById("react-root")?.dataset?.userEmail || null
const signedIn = document.getElementById("react-root")?.dataset?.signedIn === "true" || false

export default function MobileNav({ feeds, unreadCount, bookmarkCount, activeItem, onSelect }) {
  const [showSettings, setShowSettings] = useState(false)

  return (
    <>
      <div className="flex flex-col h-screen overflow-y-auto sidebar-scroll"
        style={{ background: "var(--sidebar-bg)" }}>
        <div className="flex items-center justify-between px-5 py-4 border-b"
          style={{ borderColor: "var(--border)" }}>
          <a className="logo-wordmark" href="/">RSSReader</a>
          <button
            type="button"
            onClick={() => setShowSettings((s) => !s)}
            className="border-none bg-transparent cursor-pointer text-lg p-1"
            style={{ color: "var(--text-faint)" }}
          >
            ⚙
          </button>
        </div>

        <div className="px-2 pt-4">
          <a
            href="/"
            className={`nav-primary${!activeItem || activeItem.type === "unread" ? " active" : ""}`}
            onClick={(e) => { e.preventDefault(); onSelect({ type: "unread" }) }}
          >
            <span>Unread</span>
            {unreadCount != null && <span className="badge">{unreadCount}</span>}
          </a>
          <a
            href="/v2/bookmarks"
            className={`nav-primary${activeItem?.type === "bookmarks" ? " active" : ""}`}
            onClick={(e) => { e.preventDefault(); onSelect({ type: "bookmarks" }) }}
          >
            <span>Bookmarks</span>
            {bookmarkCount != null && <span className="badge">{bookmarkCount}</span>}
          </a>
        </div>

        <div className="divider" />
        <div className="px-2 flex-1">
          <FeedsDropdown feeds={feeds} activeItem={activeItem} onSelect={onSelect} />
        </div>

        <div className="px-4 py-4 border-t" style={{ borderColor: "var(--border)" }}>
          <p className="text-[0.72rem] truncate" style={{ color: "var(--text-muted)" }}>
            {userEmail || ""}
          </p>
        </div>
      </div>

      {showSettings && (
        <SettingsModal signedIn={signedIn} userEmail={userEmail} onClose={() => setShowSettings(false)} />
      )}
    </>
  )
}
