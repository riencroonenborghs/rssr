import React from "react"

function formatDate(iso) {
  if (!iso) return null
  const d = new Date(iso)
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" })
}

export default function EntryDetail({ entry }) {
  if (!entry) {
    return (
      <div className="flex-1 h-screen flex items-center justify-center text-sm"
        style={{ color: "var(--text-faint)" }}>
        Select an entry to read
      </div>
    )
  }

  return (
    <div className="flex-1 h-screen overflow-y-auto px-12 py-10 sidebar-scroll">
      <div className="mb-6">
        <h1 className="text-[1.6rem] font-semibold leading-[1.3] mb-3"
          style={{ fontFamily: "'Playfair Display', serif", color: "var(--text-primary)" }}>
          {entry.title}
        </h1>
        <div className="flex gap-3 text-[0.75rem]" style={{ color: "var(--text-muted)" }}>
          <span>{entry.feed?.title}</span>
          {entry.published_at && <><span>·</span><span>{formatDate(entry.published_at)}</span></>}
          {entry.link && (
            <>
              <span>·</span>
              <a href={entry.link} target="_blank" rel="noopener noreferrer"
                className="no-underline" style={{ color: "var(--accent)" }}>
                Original ↗
              </a>
            </>
          )}
        </div>
      </div>
      <div className="text-[0.92rem] leading-7" style={{ color: "var(--text-primary)" }}
        dangerouslySetInnerHTML={{ __html: entry.description || "<p>No content available.</p>" }}
      />
    </div>
  )
}
