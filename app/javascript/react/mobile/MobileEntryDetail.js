import React, { useState } from "react"
import { formatDateHHMM } from "../hooks/useDateFormat"
import { ExternalLink, Bookmark, BookmarkCheck, ArrowLeft } from "lucide-react"
import { createBookmark, deleteBookmark } from "../api/bookmarks";
import { signedIn } from "../hooks/useSignedin"

export default function MobileEntryDetail({ entry, loading, onBack }) {
  const [bookmarked, setBookmarked] = useState(entry?.bookmarked)

  const handleCreateBookmark = () => {
    createBookmark(entry.id).then(() => setBookmarked(true))
  }
  const handleDeleteBookmark = () => {
    deleteBookmark(entry.id).then(() => setBookmarked(false))
  }

  return (
    <div className="flex flex-col h-screen" style={{ background: "var(--sidebar-bg)" }}>
      <div className="flex items-center gap-3 px-4 py-3 border-b shrink-0"
        style={{ borderColor: "var(--border)" }}>
        <button
          type="button"
          onClick={onBack}
          className="border-none bg-transparent cursor-pointer text-[1.1rem] p-0 leading-none flex items-center gap-x-2"
          style={{ color: "var(--text-muted)" }}
        >
          <ArrowLeft size={16}></ArrowLeft>
          {entry && (
            <h2 className="m-0 text-[0.7rem] font-medium tracking-[0.14em] uppercase"
              style={{ color: "var(--text-muted)" }}>
              {entry.feed?.title}
            </h2>
          )}
        </button>
      </div>

      <div className="overflow-y-auto flex-1 sidebar-scroll px-5 py-6">
        {loading ? (
          <div className="py-12 text-sm text-center" style={{ color: "var(--text-faint)" }}>Loading…</div>
        ) : !entry ? null : (
          <>
            <h1 className="text-[1.4rem] font-semibold leading-[1.3] mb-3"
              style={{ fontFamily: "'Playfair Display', serif", color: "var(--text-primary)" }}>
              {entry.title}
            </h1>
            <div className="flex gap-3 text-[0.72rem] mb-6" style={{ color: "var(--text-muted)" }}>
              {signedIn && bookmarked && <BookmarkCheck size={16} className="cursor-pointer" onClick={handleDeleteBookmark}></BookmarkCheck>}
              {signedIn && !bookmarked && <Bookmark size={16} className="cursor-pointer" onClick={handleCreateBookmark}></Bookmark>}
              {entry.published_at && <span>{formatDateHHMM(entry.published_at)}</span>}
              {entry.link && (
                <>
                  <span>·</span>
                  <a href={entry.link} target="_blank" rel="noopener noreferrer"
                    className="no-underline flex flex-row items-center gap-x-2" style={{ color: "var(--accent)" }}>
                    Original
                    <ExternalLink size={12}></ExternalLink>
                  </a>
                </>
              )}
            </div>
            <div className="text-[0.92rem] leading-7" style={{ color: "var(--text-primary)" }}
              dangerouslySetInnerHTML={{ __html: entry.description || "<p>No content available.</p>" }}
            />
          </>
        )}
      </div>
    </div>
  )
}
