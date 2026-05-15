import React from "react"

function formatDate(iso) {
  if (!iso) return null
  return new Date(iso).toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" })
}

export default function DailyReportsList({ title, dailyReports, loading, activeEntry, onSelect }) {
  return (
    <div className="flex flex-col h-screen border-r" style={{ width: "320px", minWidth: "320px", borderColor: "var(--border)" }}>
      <div className="px-5 py-4 border-b shrink-0" style={{ borderColor: "var(--border)" }}>
        <h2 className="text-[0.82rem] font-semibold tracking-wide uppercase" style={{ color: "var(--text-muted)" }}>
          {title || "Daily Reports"}
        </h2>
      </div>
      <div className="flex-1 overflow-y-auto sidebar-scroll">
        {loading && (
          <div className="flex items-center justify-center py-12 text-sm" style={{ color: "var(--text-faint)" }}>
            Loading…
          </div>
        )}
        {!loading && dailyReports.length === 0 && (
          <div className="flex items-center justify-center py-12 text-sm" style={{ color: "var(--text-faint)" }}>
            No reports
          </div>
        )}
        {!loading && dailyReports.map((dr) => {
          const isActive = activeEntry?.id === dr.id
          return (
            <div
              key={dr.id}
              className="px-4 py-3 cursor-pointer border-b"
              style={{
                borderColor: "var(--border)",
                background: isActive ? "var(--hover-bg)" : "transparent",
              }}
              onClick={() => onSelect({ type: "daily_report", id: dr.id, reportId: dr.report?.id })}
              onMouseEnter={(e) => { if (!isActive) e.currentTarget.style.background = "var(--hover-bg)" }}
              onMouseLeave={(e) => { if (!isActive) e.currentTarget.style.background = "transparent" }}
            >
              <div className="text-[0.85rem] font-medium mb-1" style={{ color: "var(--text-primary)" }}>
                {formatDate(dr.created_at)}
              </div>
              {dr.report?.keywords?.length > 0 && (
                <div className="text-[0.75rem]" style={{ color: "var(--text-muted)" }}>
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
