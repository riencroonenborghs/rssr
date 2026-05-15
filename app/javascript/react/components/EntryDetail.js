import React from "react"

export default function EntryDetail({ entry }) {
  if (!entry) {
    return (
      <div style={{
        flex: 1,
        height: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        color: "var(--text-faint)",
        fontSize: "0.85rem",
      }}>
        Select an entry to read
      </div>
    )
  }

  return (
    <div style={{
      flex: 1,
      height: "100vh",
      overflowY: "auto",
      padding: "2.5rem 3rem",
      maxWidth: 720,
    }} className="sidebar-scroll">
      <div style={{ marginBottom: "1.5rem" }}>
        <h1 style={{
          fontFamily: "'Playfair Display', serif",
          fontSize: "1.6rem",
          fontWeight: 600,
          color: "var(--text-primary)",
          lineHeight: 1.3,
          marginBottom: "0.75rem",
        }}>
          {entry.title}
        </h1>
        <div style={{
          fontSize: "0.75rem",
          color: "var(--text-muted)",
          display: "flex",
          gap: "0.75rem",
        }}>
          <span>{entry.feed}</span>
          {entry.date && <><span>·</span><span>{entry.date}</span></>}
          {entry.url && (
            <>
              <span>·</span>
              <a
                href={entry.url}
                target="_blank"
                rel="noopener noreferrer"
                style={{ color: "var(--accent)", textDecoration: "none" }}
              >
                Original ↗
              </a>
            </>
          )}
        </div>
      </div>
      <div style={{
        fontSize: "0.92rem",
        lineHeight: 1.75,
        color: "var(--text-primary)",
      }}
        dangerouslySetInnerHTML={{ __html: entry.content || "<p>No content available.</p>" }}
      />
    </div>
  )
}
