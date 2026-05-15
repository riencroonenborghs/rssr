import React, { useState, useEffect } from "react"
import FeedsDropdown from "./FeedsDropdown"
import ReportsDropdown from "./ReportsDropdown"
import SettingsModal from "./SettingsModal"
import { fetchReports } from "../api/reports"

const userEmail = document.getElementById("react-root")?.dataset?.userEmail || null
const signedIn = document.getElementById("react-root")?.dataset?.signedIn === "true" || false

export default function Sidebar({ feeds = [], unreadCount, bookmarkCount, activeItem, onSelect }) {
  const [showSettings, setShowSettings] = useState(false)
  const [reports, setReports] = useState([])

  useEffect(() => {
    fetchReports().then((data) => setReports(data.reports || []))
  }, [])

  return (
    <>
      <aside className="flex flex-col justify-between h-screen w-[232px] min-w-[232px] border-r"
        style={{ background: "var(--sidebar-bg)", borderColor: "var(--border)" }}>
        <div className="flex flex-col overflow-hidden flex-1">
          <div className="px-5 py-5 border-b shrink-0" style={{ borderColor: "var(--border)" }}>
            <a className="logo-wordmark" href="/react">RSSReader</a>
          </div>
          <div className="overflow-y-auto flex-1 sidebar-scroll">
            <div className="px-2 pt-4">
              <a
                href="/react"
                className={`nav-primary${!activeItem || activeItem.type === "unread" ? " active" : ""}`}
                onClick={(e) => { e.preventDefault(); onSelect({ type: "unread" }) }}
              >
                <span>Unread</span>
                {unreadCount != null && <span className="badge">{unreadCount}</span>}
              </a>
              {bookmarkCount != null && <a
                href="/react/bookmarks"
                className={`nav-primary${activeItem?.type === "bookmarks" ? " active" : ""}`}
                onClick={(e) => { e.preventDefault(); onSelect({ type: "bookmarks" }) }}
              >
                <span>Bookmarks</span>
                <span className="badge">{bookmarkCount}</span>
              </a>}
            </div>
            <div className="divider" />
            <div className="px-2">
              <FeedsDropdown feeds={feeds} activeItem={activeItem} onSelect={onSelect} />
            </div>
            {reports.length > 0 && (
              <>
                <div className="divider" />
                <div className="px-2">
                  <ReportsDropdown reports={reports} activeItem={activeItem} onSelect={onSelect} />
                </div>
              </>
            )}
          </div>
        </div>
        <div className="px-2 py-3 border-t shrink-0" style={{ borderColor: "var(--border)" }}>
          <button
            type="button"
            onClick={() => setShowSettings((s) => !s)}
            className="flex items-center justify-between w-full px-3 py-2 rounded cursor-pointer border-none transition-colors duration-150"
            style={{ background: showSettings ? "var(--hover-bg)" : "transparent" }}
            onMouseEnter={(e) => { e.currentTarget.style.background = "var(--hover-bg)" }}
            onMouseLeave={(e) => { if (!showSettings) e.currentTarget.style.background = "transparent" }}
          >
            <span className="text-[0.78rem] truncate max-w-[150px]" style={{ color: "var(--text-muted)" }}>
              {userEmail || "Settings"}
            </span>
            <span className="text-[0.85rem] ml-2 shrink-0" style={{ color: "var(--text-faint)" }}>⚙</span>
          </button>
        </div>
      </aside>

      {showSettings && (
        <SettingsModal signedIn={signedIn} userEmail={userEmail} onClose={() => setShowSettings(false)} />
      )}
    </>
  )
}
