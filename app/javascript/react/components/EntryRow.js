import React from "react"

function formatDate(iso) {
  if (!iso) return null
  const d = new Date(iso)
  return d.toLocaleDateString("en-GB", { day: "numeric", month: "short" })
}

export default function EntryRow({ entry, active, onSelect, onFeedSelect, onTagSelect }) {
  return (
    <div
      onClick={() => onSelect(entry)}
      className={`flex flex-row gap-3 w-full text-left border-b cursor-pointer transition-colors duration-150 p-[0.85rem_1rem] items-start select-none ${active ? "bg-[var(--hover-bg)]" : "bg-transparent hover:bg-[var(--hover-bg)]"}`}
      style={{ borderBottom: "1px solid var(--border)" }}
    >
      {entry.image && (
        <img
          src={entry.image}
          alt=""
          className="w-[52px] h-[52px] object-cover rounded shrink-0"
          style={{ background: "var(--text-faint)" }}
          onError={(e) => { e.currentTarget.style.display = "none" }}
        />
      )}
      <div className="flex-1 min-w-0">
        <div className="flex justify-between gap-[0.4rem] items-center flex-wrap text-[0.72rem] mb-[0.4rem]"
          style={{ color: "var(--text-muted)" }}>
          <a
            href={`/react?feed=${entry.feed?.id}`}
            className="hover:underline"
            style={{ color: "var(--accent-dim)" }}
            onClick={(e) => { e.preventDefault(); e.stopPropagation(); onFeedSelect(entry.feed) }}
          >
            {entry.feed?.title}
          </a>
          {entry.published_at && (
            <>
              <span>·</span>
              <span>{formatDate(entry.published_at)}</span>
            </>
          )}
        </div>
        <div className="text-[0.85rem] font-medium leading-[1.35] mb-[0.3rem] overflow-hidden line-clamp-2"
          style={{ color: "var(--text-primary)" }}>
          {entry.title}
        </div>
        {entry.tags?.length > 0 && (
          <div className="flex gap-[0.3rem] flex-wrap">
            {entry.tags.map((tag, index) => (
              <a
                key={index}
                href={`/react?tag=${tag.id}`}
                className="text-[0.5rem] px-[6px] py-[1px] rounded-full hover:underline"
                style={{ color: "var(--text-muted)", background: "rgba(255,255,255,0.05)" }}
                onClick={(e) => { e.preventDefault(); e.stopPropagation(); onTagSelect(tag) }}
              >
                #{tag.name}
              </a>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
