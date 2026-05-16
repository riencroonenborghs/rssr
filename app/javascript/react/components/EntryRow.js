import React, { useState } from "react"
import { formatDateHHMM } from "../hooks/useDateFormat"

export default function EntryRow({ entry, active, compact, onSelect, onFeedSelect, onTagSelect }) {
  const [showAllTags, setShowAllTags] = useState(false)

  return (
    <div
      onClick={() => onSelect(entry)}
      className={`flex flex-row gap-3 w-full text-left cursor-pointer transition-colors duration-150 items-start select-none ${compact ? "py-[0.45rem] px-4" : "p-[0.85rem_1rem]"}`}
      style={{
        borderBottom: "1px solid var(--entries-border)",
        background: active ? "var(--entries-hover-bg)" : "transparent",
      }}
      onMouseEnter={(e) => { if (!active) e.currentTarget.style.background = "var(--entries-hover-bg)" }}
      onMouseLeave={(e) => { if (!active) e.currentTarget.style.background = "transparent" }}
    >
      {!compact && entry.image && (
        <img
          src={entry.image}
          alt=""
          className="w-[52px] h-[52px] object-cover rounded shrink-0"
          style={{ background: "var(--entries-text-faint)" }}
          onError={(e) => { e.currentTarget.style.display = "none" }}
        />
      )}
      <div className="flex-1 min-w-0">
        <div className={`flex justify-between gap-[0.4rem] items-center flex-wrap text-[0.72rem] ${compact ? "mb-0" : "mb-[0.4rem]"}`}
          style={{ color: "var(--entries-text-faint)" }}>
          <a
            href={`/v2/feeds/${entry.feed?.id}`}
            className="hover:underline"
            style={{ color: "var(--entries-text-muted)" }}
            onClick={(e) => { e.preventDefault(); e.stopPropagation(); onFeedSelect(entry.feed) }}
          >
            {entry.feed?.title}
          </a>
          {entry.published_at && (
            <>
              <span>·</span>
              <span>{formatDateHHMM(entry.published_at)}</span>
            </>
          )}
        </div>
        <div className={`text-[0.85rem] leading-[1.35] overflow-hidden ${compact ? "line-clamp-1" : "line-clamp-2 mb-[0.3rem]"} ${entry.viewed ? "font-normal" : "font-medium"}`}
          style={{ color: entry.viewed ? "var(--entries-text-muted)" : "var(--entries-text-primary)" }}>
          {entry.title}
        </div>
        {!compact && entry.tags?.length > 0 && (
          <div className="flex gap-[0.3rem] flex-wrap">
            {(showAllTags ? entry.tags : entry.tags.slice(0, 3)).map((tag, index) => (
              <a
                key={index}
                href={`/v2/tags/${tag.id}`}
                className="text-[0.5rem] px-[6px] py-[1px] rounded-full hover:underline"
                style={{ color: "var(--entries-text-muted)", background: "rgba(0,0,0,0.06)" }}
                onClick={(e) => { e.preventDefault(); e.stopPropagation(); onTagSelect(tag) }}
              >
                #{tag.name}
              </a>
            ))}
            {!showAllTags && entry.tags.length > 3 && (
              <button
                type="button"
                className="text-[0.5rem] px-[6px] py-[1px] rounded-full border-none cursor-pointer"
                style={{ color: "var(--entries-text-muted)", background: "rgba(0,0,0,0.06)" }}
                onClick={(e) => { e.stopPropagation(); setShowAllTags(true) }}
              >
                +{entry.tags.length - 3}
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}
