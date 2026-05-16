import React, { useState } from "react"
import { ChevronDown } from "lucide-react"

export default function FeedsDropdown({ feeds, activeItem, onSelect }) {
  const [open, setOpen] = useState(true)

  return (
    <div>
      <button
        className="feeds-toggle"
        type="button"
        onClick={() => setOpen((o) => !o)}
      >
        <span>Feeds</span>
        <span
          className="arrow"
          style={{ transform: open ? "rotate(0deg)" : "rotate(-90deg)" }}
        >
          <ChevronDown size={12}></ChevronDown>
        </span>
      </button>
      {open && (
        <div className="flex flex-col overflow-auto sidebar-scroll mt-1" style={{ maxHeight: "calc(100vh - 420px)" }}>
          {feeds.map((feed, index) => (
            <a
              key={index}
              href={`/v2/feeds/${feed.id}`}
              className={`sidebar-link${activeItem?.id === feed.id && activeItem?.type === "feed" ? " active" : ""}`}
              onClick={(e) => { e.preventDefault(); onSelect({ type: "feed", ...feed }) }}
            >
              <span>{feed.title}</span>
              <span className="badge">{feed.count}</span>
            </a>
          ))}
        </div>
      )}
    </div>
  )
}
