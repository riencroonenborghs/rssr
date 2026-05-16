import React from "react"
import Markdown from "react-markdown"
import { formatDate } from "../hooks/useDateFormat"

export default function DailyReportDetail({ report, loading }) {
  if (loading) {
    return (
      <div className="flex-1 h-screen flex items-center justify-center text-sm"
        style={{ background: "var(--detail-bg)", color: "var(--detail-text-muted)" }}>
        Loading…
      </div>
    )
  }

  if (!report) {
    return (
      <div className="flex-1 h-screen flex items-center justify-center text-sm"
        style={{ background: "var(--detail-bg)", color: "var(--detail-text-muted)" }}>
        Select a report to read
      </div>
    )
  }

  return (
    <div className="flex-1 h-screen overflow-y-auto px-12 py-10 sidebar-scroll"
      style={{ background: "var(--detail-bg)" }}>
      <div className="mb-6">
        <div className="text-[0.7rem] font-medium tracking-[0.14em] uppercase mb-2"
          style={{ color: "var(--detail-text-muted)" }}>
          {report.report?.keywords?.join(", ")}
        </div>
        <h1 className="text-[1.6rem] font-semibold leading-[1.3] mb-3"
          style={{ fontFamily: "'Playfair Display', serif", color: "var(--detail-text-primary)" }}>
          Daily Report
        </h1>
        <div className="text-[0.75rem]" style={{ color: "var(--detail-text-muted)" }}>
          {formatDate(report.created_at)}
        </div>
      </div>
      <div className="text-[0.92rem] leading-7" style={{ color: "var(--detail-text-primary)" }}>
        <Markdown>{report.summary}</Markdown>
      </div>
    </div>
  )
}
