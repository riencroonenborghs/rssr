import { api } from "./client"

export function fetchReports() {
  return api.get("/reports")
}

export function fetchDailyReports(reportId) {
  return api.get(`/reports/${reportId}/daily`)
}

export function fetchDailyReport(reportId, dailyId) {
  return api.get(`/reports/${reportId}/daily/${dailyId}`)
}
