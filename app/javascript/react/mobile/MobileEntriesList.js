import React from "react"
import EntryRow from "../components/EntryRow"

export default function MobileEntriesList({ title, entries = [], loading, onSelect, onFeedSelect, onTagSelect, onBack }) {
  return (
    <div className="flex flex-col h-screen" style={{ background: "var(--sidebar-surface)" }}>
      <div className="flex items-center gap-3 px-4 py-3 border-b shrink-0"
        style={{ borderColor: "var(--border)" }}>
        <button
          type="button"
          onClick={onBack}
          className="border-none bg-transparent cursor-pointer text-[1.1rem] p-0 leading-none"
          style={{ color: "var(--text-muted)" }}
        >
          ←
        </button>
        <h2 className="m-0 text-[0.7rem] font-medium tracking-[0.14em] uppercase"
          style={{ color: "var(--text-muted)" }}>
          {title || "Entries"}
        </h2>
      </div>
      <div className="overflow-y-auto flex-1 sidebar-scroll">
        {loading ? (
          <div className="py-12 text-sm text-center" style={{ color: "var(--text-muted)" }}>Loading…</div>
        ) : entries.length === 0 ? (
          <div className="py-12 text-sm text-center" style={{ color: "var(--text-muted)" }}>No entries</div>
        ) : (
          entries.map((entry) => (
            <EntryRow
              key={entry.id}
              entry={entry}
              active={false}
              compact={false}
              onSelect={onSelect}
              onFeedSelect={onFeedSelect}
              onTagSelect={onTagSelect}
            />
          ))
        )}
      </div>
    </div>
  )
}
