import React from "react"
import { formatDate } from "../hooks/useDateFormat"

export default function DailyReportsList({ title, dailyReports, loading, activeEntry, onSelect }) {
  return (
    <div className="flex flex-col h-screen border-r" style={{ width: "320px", minWidth: "320px", background: "var(--entries-bg)", borderColor: "var(--entries-border)" }}>
      <div className="px-5 py-4 border-b shrink-0" style={{ borderColor: "var(--entries-border)" }}>
        <h2 className="text-[0.7rem] font-medium tracking-[0.14em] uppercase" style={{ color: "var(--entries-text-muted)" }}>
          {title || "Daily Reports"}
        </h2>
      </div>
      <div className="flex-1 overflow-y-auto sidebar-scroll">
        {loading && (
          <div className="flex items-center justify-center py-12 text-sm" style={{ color: "var(--entries-text-muted)" }}>
            Loading…
          </div>
        )}
        {!loading && dailyReports.length === 0 && (
          <div className="flex items-center justify-center py-12 text-sm" style={{ color: "var(--entries-text-muted)" }}>
            No reports
          </div>
        )}
        {!loading && dailyReports.map((dr) => {
          const isActive = activeEntry?.id === dr.id
          return (
            <div
              key={dr.id}
              className="px-4 py-3 cursor-pointer"
              style={{
                borderBottom: "1px solid var(--entries-border)",
                background: isActive ? "var(--entries-hover-bg)" : "transparent",
              }}
              onClick={() => onSelect({ type: "daily_report", id: dr.id, reportId: dr.report?.id })}
              onMouseEnter={(e) => { if (!isActive) e.currentTarget.style.background = "var(--entries-hover-bg)" }}
              onMouseLeave={(e) => { if (!isActive) e.currentTarget.style.background = "transparent" }}
            >
              <div className="text-[0.85rem] font-medium mb-1" style={{ color: "var(--entries-text-primary)" }}>
                {formatDate(dr.created_at)}
              </div>
              {dr.report?.keywords?.length > 0 && (
                <div className="text-[0.75rem]" style={{ color: "var(--entries-text-faint)" }}>
                  {dr.report.keywords.join(", ")}
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}
