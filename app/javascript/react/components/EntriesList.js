import React from "react"
import EntryRow from "./EntryRow"
import { useSettings } from "../context/SettingsContext"
import { useEndlessScroll } from "../hooks/useEndlessScroll"

export default function EntriesList({ title, entries = [], loading, loadingMore, hasMore, onLoadMore, activeEntry, onSelect, onFeedSelect, onTagSelect }) {
  const { density } = useSettings()
  const scrollRef = useEndlessScroll(onLoadMore, hasMore && !loadingMore)

  return (
    <div className="flex flex-col h-screen w-[340px] min-w-[340px] overflow-hidden border-r"
      style={{ background: "var(--entries-bg)", borderColor: "var(--entries-border)" }}>
      <div className="px-4 py-4 border-b" style={{ borderColor: "var(--entries-border)" }}>
        <h2 className="m-0 text-[0.7rem] font-medium tracking-[0.14em] uppercase"
          style={{ color: "var(--entries-text-muted)" }}>
          {title || "Entries"}
        </h2>
      </div>
      <div ref={scrollRef} className="overflow-y-auto flex-1 sidebar-scroll">
        {loading ? (
          <div className="py-8 px-4 text-sm text-center" style={{ color: "var(--entries-text-muted)" }}>
            Loading…
          </div>
        ) : entries.length === 0 ? (
          <div className="py-8 px-4 text-sm text-center" style={{ color: "var(--entries-text-muted)" }}>
            No entries
          </div>
        ) : (
          <>
            {entries.map((entry) => (
              <EntryRow
                key={entry.id}
                entry={entry}
                active={activeEntry?.id === entry.id}
                compact={density === "compact"}
                onSelect={onSelect}
                onFeedSelect={onFeedSelect}
                onTagSelect={onTagSelect}
              />
            ))}
            {loadingMore && (
              <div className="py-4 text-center text-[0.75rem]" style={{ color: "var(--entries-text-faint)" }}>
                Loading…
              </div>
            )}
          </>
        )}
      </div>
    </div>
  )
}
