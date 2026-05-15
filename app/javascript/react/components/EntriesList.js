import React from "react"
import EntryRow from "./EntryRow"

export default function EntriesList({ title, entries = [], loading, activeEntry, onSelect }) {
  return (
    <div style={{
      width: 340,
      minWidth: 340,
      height: "100vh",
      background: "var(--sidebar-surface)",
      borderRight: "1px solid var(--border)",
      display: "flex",
      flexDirection: "column",
      overflow: "hidden",
    }}>
      <div className="px-4 py-4" style={{ borderBottom: "1px solid var(--border)" }}>
        <h2 style={{
          fontFamily: "'DM Sans', sans-serif",
          fontSize: "0.7rem",
          fontWeight: 500,
          letterSpacing: "0.14em",
          textTransform: "uppercase",
          color: "var(--text-muted)",
          margin: 0,
        }}>
          {title || "Entries"}
        </h2>
      </div>
      <div style={{ overflowY: "auto", flex: 1 }} className="sidebar-scroll">
        {loading ? (
          <div style={{ padding: "2rem 1rem", color: "var(--text-muted)", fontSize: "0.85rem", textAlign: "center" }}>
            Loading…
          </div>
        ) : entries.length === 0 ? (
          <div style={{ padding: "2rem 1rem", color: "var(--text-muted)", fontSize: "0.85rem", textAlign: "center" }}>
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
