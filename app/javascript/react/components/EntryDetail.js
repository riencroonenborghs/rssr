import React, { useRef, useEffect } from "react"
import { formatDateHHMM } from "../hooks/useDateFormat"

export default function EntryDetail({ entry, loading }) {
  const contentRef = useRef(null)

  useEffect(() => {
    if (!contentRef.current) return
    contentRef.current.querySelectorAll("a").forEach((a) => {
      a.setAttribute("target", "_blank")
      a.setAttribute("rel", "noopener noreferrer")
    })
  }, [entry])

  if (loading) {
    return (
      <div className="flex-1 h-screen flex items-center justify-center text-sm"
        style={{ background: "var(--detail-bg)", color: "var(--detail-text-muted)" }}>
        Loading…
      </div>
    )
  }

  if (!entry) {
    return (
      <div className="flex-1 h-screen flex items-center justify-center text-sm"
        style={{ background: "var(--detail-bg)", color: "var(--detail-text-muted)" }}>
        Select an entry to read
      </div>
    )
  }

  return (
    <div className="flex-1 h-screen overflow-y-auto px-12 py-10 sidebar-scroll"
      style={{ background: "var(--detail-bg)" }}>
      <div className="mb-6">
        <h1 className="text-[1.6rem] font-semibold leading-[1.3] mb-3"
          style={{ fontFamily: "'Playfair Display', serif", color: "var(--detail-text-primary)" }}>
          {entry.title}
        </h1>
        <div className="flex gap-3 text-[0.75rem]" style={{ color: "var(--detail-text-muted)" }}>
          <span>{entry.feed?.title}</span>
          {entry.published_at && <><span>·</span><span>{formatDateHHMM(entry.published_at)}</span></>}
          {entry.link && (
            <>
              <span>·</span>
              <a href={entry.link} target="_blank" rel="noopener noreferrer"
                className="no-underline" style={{ color: "var(--detail-accent)" }}>
                Original ↗
              </a>
            </>
          )}
        </div>
      </div>
      <div ref={contentRef} className="text-[0.92rem] leading-7" style={{ color: "var(--detail-text-primary)" }}
        dangerouslySetInnerHTML={{ __html: entry.description || "<p>No content available.</p>" }}
      />
    </div>
  )
}
