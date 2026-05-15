import React from "react"

function formatDate(iso) {
  if (!iso) return null
  const d = new Date(iso)
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" })
}

function EntryRow({ entry, active, onSelect }) {
  return (
    <button
      onClick={() => onSelect(entry)}
      style={{
        display: "flex",
        flexDirection: "row",
        gap: "0.75rem",
        width: "100%",
        textAlign: "left",
        background: active ? "var(--hover-bg)" : "transparent",
        border: "none",
        borderBottom: "1px solid var(--border)",
        padding: "0.85rem 1rem",
        cursor: "pointer",
        transition: "background 0.15s ease",
        alignItems: "flex-start",
      }}
      onMouseEnter={(e) => { if (!active) e.currentTarget.style.background = "var(--hover-bg)" }}
      onMouseLeave={(e) => { if (!active) e.currentTarget.style.background = "transparent" }}
    >
      {entry.image && (
        <img
          src={entry.image}
          alt=""
          style={{
            width: 52,
            height: 52,
            objectFit: "cover",
            borderRadius: 4,
            flexShrink: 0,
            background: "var(--text-faint)",
          }}
          onError={(e) => { e.currentTarget.style.display = "none" }}
        />
      )}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontSize: "0.85rem",
          fontWeight: 500,
          color: "var(--text-primary)",
          lineHeight: 1.35,
          marginBottom: "0.3rem",
          overflow: "hidden",
          display: "-webkit-box",
          WebkitLineClamp: 2,
          WebkitBoxOrient: "vertical",
        }}>
          {entry.title}
        </div>
        <div style={{
          fontSize: "0.72rem",
          color: "var(--text-muted)",
          display: "flex",
          gap: "0.4rem",
          alignItems: "center",
          flexWrap: "wrap",
          marginBottom: entry.tags?.length ? "0.4rem" : 0,
        }}>
          <span style={{ color: "var(--accent-dim)" }}>{entry.feed?.title}</span>
          {entry.published_at && (
            <>
              <span>·</span>
              <span>{formatDate(entry.published_at)}</span>
            </>
          )}
        </div>
        {entry.tags?.length > 0 && (
          <div style={{ display: "flex", gap: "0.3rem", flexWrap: "wrap" }}>
            {entry.tags.map((tag) => (
              <span key={tag.id} style={{
                fontSize: "0.65rem",
                color: "var(--text-muted)",
                background: "rgba(255,255,255,0.05)",
                padding: "1px 6px",
                borderRadius: 99,
              }}>
                {tag.name}
              </span>
            ))}
          </div>
        )}
      </div>
    </button>
  )
}

export default function EntriesList({ title, entries = [], loading, activeEntry, onSelect }) {
  return (
    <div style={{
      width: 340,
      minWidth: 340,
      height: "100vh",
      background: "var(--sidebar-surface)",
      borderRight: "1px solid var(--border)",
      display: "flex",
      flexDirection: "column",
      overflow: "hidden",
    }}>
      <div className="px-4 py-4" style={{ borderBottom: "1px solid var(--border)" }}>
        <h2 style={{
          fontFamily: "'DM Sans', sans-serif",
          fontSize: "0.7rem",
          fontWeight: 500,
          letterSpacing: "0.14em",
          textTransform: "uppercase",
          color: "var(--text-muted)",
          margin: 0,
        }}>
          {title || "Entries"}
        </h2>
      </div>
      <div style={{ overflowY: "auto", flex: 1 }} className="sidebar-scroll">
        {loading ? (
          <div style={{ padding: "2rem 1rem", color: "var(--text-muted)", fontSize: "0.85rem", textAlign: "center" }}>
            Loading…
          </div>
        ) : entries.length === 0 ? (
          <div style={{ padding: "2rem 1rem", color: "var(--text-muted)", fontSize: "0.85rem", textAlign: "center" }}>
            No entries
          </div>
        ) : (
          entries.map((entry) => (
            <EntryRow
              key={entry.id}
              entry={entry}
              active={activeEntry?.id === entry.id}
              onSelect={onSelect}
            />
          ))
        )}
      </div>
    </div>
  )
}
