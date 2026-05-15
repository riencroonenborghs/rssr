import React from "react"
import FeedsDropdown from "./FeedsDropdown"

const MANAGE_LINKS = [
  { label: "Subscriptions", path: "/subscriptions" },
  { label: "Filters", path: "/filters" },
  { label: "Sidekiq", path: "/sidekiq", external: true },
]

export default function Sidebar({ feeds = [], unreadCount, bookmarkCount, activeItem, onSelect }) {
  return (
    <aside className="flex flex-col justify-between h-screen w-[232px] min-w-[232px] border-r"
      style={{ background: "var(--sidebar-bg)", borderColor: "var(--border)" }}>
      <div>
        <div className="px-5 py-5 border-b" style={{ borderColor: "var(--border)" }}>
          <a className="logo-wordmark" href="/react">RSSReader</a>
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
            href="/react/bookmarks"
            className={`nav-primary${activeItem?.type === "bookmarks" ? " active" : ""}`}
            onClick={(e) => { e.preventDefault(); onSelect({ type: "bookmarks" }) }}
          >
            <span>Bookmarks</span>
            {bookmarkCount != null && <span className="badge">{bookmarkCount}</span>}
          </a>
        </div>
        <div className="divider" />
        <div className="px-2">
          <FeedsDropdown feeds={feeds} activeItem={activeItem} onSelect={onSelect} />
        </div>
      </div>
      <div className="px-2 py-4 border-t" style={{ borderColor: "var(--border)" }}>
        <p className="section-label mb-2">Manage</p>
        {MANAGE_LINKS.map((link) => (
          <a
            key={link.path}
            href={link.path}
            className="manage-link"
            target={link.external ? "_blank" : undefined}
            rel={link.external ? "noopener noreferrer" : undefined}
          >
            {link.label}
          </a>
        ))}
      </div>
    </aside>
  )
}
