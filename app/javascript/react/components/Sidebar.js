import React from "react"
import FeedsDropdown from "./FeedsDropdown"

const NAV_ITEMS = [
  { label: "Unread", path: "/", badge: null },
  { label: "Bookmarks", path: "/bookmarks", badge: null },
]

const MANAGE_LINKS = [
  { label: "Subscriptions", path: "/subscriptions" },
  { label: "Filters", path: "/filters" },
  { label: "Sidekiq", path: "/sidekiq", external: true },
]

export default function Sidebar({ feeds = [], activeItem, onSelect }) {
  return (
    <aside style={{
      width: 232,
      minWidth: 232,
      height: "100vh",
      background: "var(--sidebar-bg)",
      borderRight: "1px solid var(--border)",
      display: "flex",
      flexDirection: "column",
      justifyContent: "space-between",
    }}>
      <div>
        <div className="px-5 py-5" style={{ borderBottom: "1px solid var(--border)" }}>
          <a className="logo-wordmark" href="/react">RSSReader</a>
        </div>
        <div className="px-2 pt-4">
          {NAV_ITEMS.map((item) => (
            <a
              key={item.path}
              href={item.path}
              className={`nav-primary${activeItem?.path === item.path ? " active" : ""}`}
              onClick={(e) => { e.preventDefault(); onSelect({ type: "nav", ...item }) }}
            >
              <span>{item.label}</span>
              {item.badge != null && <span className="badge">{item.badge}</span>}
            </a>
          ))}
        </div>
        <div className="divider" />
        <div className="px-2">
          <FeedsDropdown feeds={feeds} activeItem={activeItem} onSelect={onSelect} />
        </div>
      </div>
      <div className="px-2 py-4" style={{ borderTop: "1px solid var(--border)" }}>
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
