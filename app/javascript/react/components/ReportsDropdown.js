import React, { useState } from "react"
import { ChevronDown } from "lucide-react"

export default function ReportsDropdown({ reports, activeItem, onSelect }) {
  const [open, setOpen] = useState(false)

  if (!reports?.length) return null

  return (
    <div>
      <button
        className="reports-toggle"
        type="button"
        onClick={() => setOpen((o) => !o)}
      >
        <span>Reports</span>
        <span className="arrow" style={{ transform: open ? "rotate(0deg)" : "rotate(-90deg)" }}>
          <ChevronDown size={12}></ChevronDown>
        </span>
      </button>
      {open && (
        <div className="flex flex-col mt-1">
          {reports.map((report) => (
            <a
              key={report.id}
              href={`/v2/reports/${report.id}`}
              className={`sidebar-link text-[0.82rem]${activeItem?.type === "report" && activeItem?.id === report.id ? " active" : ""}`}
              onClick={(e) => { e.preventDefault(); onSelect({ type: "report", id: report.id, title: report.keywords?.join(", ") }) }}
            >
              <span>{report.keywords?.join(", ")}</span>
            </a>
          ))}
        </div>
      )}
    </div>
  )
}
