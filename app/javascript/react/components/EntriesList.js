import React from "react"
import EntryRow from "./EntryRow"

export default function EntriesList({ title, entries = [], loading, activeEntry, onSelect }) {
  return (
    <div className="flex flex-col h-screen w-[340px] min-w-[340px] overflow-hidden border-r"
      style={{ background: "var(--sidebar-surface)", borderColor: "var(--border)" }}>
      <div className="px-4 py-4 border-b" style={{ borderColor: "var(--border)" }}>
        <h2 className="m-0 text-[0.7rem] font-medium tracking-[0.14em] uppercase"
          style={{ color: "var(--text-muted)" }}>
          {title || "Entries"}
        </h2>
      </div>
      <div className="overflow-y-auto flex-1 sidebar-scroll">
        {loading ? (
          <div className="py-8 px-4 text-sm text-center" style={{ color: "var(--text-muted)" }}>
            Loading…
          </div>
        ) : entries.length === 0 ? (
          <div className="py-8 px-4 text-sm text-center" style={{ color: "var(--text-muted)" }}>
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
