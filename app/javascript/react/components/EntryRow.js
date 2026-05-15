import React from "react"

function formatDate(iso) {
  if (!iso) return null
  const d = new Date(iso)
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" })
}

export default function EntryRow({ entry, active, onSelect }) {
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
