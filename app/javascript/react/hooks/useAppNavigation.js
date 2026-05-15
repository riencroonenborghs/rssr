function buildUrl(navItem, entry) {
  if (entry) return `/v2/feeds/${entry.feed.id}/entries/${entry.id}`
  if (!navItem) return "/"
  if (navItem.type === "feed") return `/v2/feeds/${navItem.id}`
  if (navItem.type === "tag") return `/v2/tags/${navItem.id}`
  if (navItem.type === "bookmarks") return "/v2/bookmarks"
  if (navItem.type === "report") return `/v2/reports/${navItem.id}`
  if (navItem.type === "daily_report") return `/v2/reports/${navItem.reportId}/daily/${navItem.id}`
  return "/"
}

export function pushUrl(navItem, entry) {
  const url = buildUrl(navItem, entry)
  if (url !== window.location.pathname) {
    window.history.pushState({}, "", url)
  }
}

export function parseUrl() {
  const parts = window.location.pathname.replace(/^\/v2\/?/, "").split("/")
  if (parts[0] === "bookmarks") return { view: "bookmarks" }
  if (parts[0] === "feeds" && parts[1] && parts[2] === "entries" && parts[3]) {
    return { feedId: parts[1], entryId: parts[3] }
  }
  if (parts[0] === "feeds" && parts[1]) return { feedId: parts[1] }
  if (parts[0] === "tags" && parts[1]) return { tagId: parts[1] }
  if (parts[0] === "reports" && parts[1] && parts[2] === "daily" && parts[3]) {
    return { reportId: parts[1], dailyId: parts[3] }
  }
  if (parts[0] === "reports" && parts[1]) return { reportId: parts[1] }
  return {}
}
