import { Bookmark, Funnel, LayoutDashboard, ListTree, Plus, Rss, Search, Settings } from "lucide-react"

// The app's sections, shown in the desktop sidebar and the mobile menu. A section is active on
// its path and the paths below it, unless exact; the dashboard's entries live under /entries.
export const mainItems = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, paths: [ "/entries" ] },
  { to: "/feeds", label: "Feeds", icon: Rss },
  { to: "/bookmarks", label: "Bookmarks", icon: Bookmark },
  { to: "/search", label: "Search", icon: Search }
]

// Shown at the bottom of the navigation.
export const footerItems = [
  { to: "/settings", label: "Settings", icon: Settings }
]
export const signedInFooterItems = [
  { to: "/subscriptions", label: "Subscriptions", icon: ListTree, exact: true },
  { to: "/subscriptions/new", label: "Add a feed", icon: Plus },
  { to: "/filters", label: "Filters", icon: Funnel }
]

const isUnder = (pathname, path) => pathname === path || pathname.startsWith(`${path}/`)

export function isActiveItem(item, pathname) {
  if (item.to === "/") return pathname === "/" || (item.paths ?? []).some((path) => isUnder(pathname, path))
  if (item.exact) return pathname === item.to
  return isUnder(pathname, item.to)
}

// The section the path belongs to, e.g. "/feeds/1/entries/2" is in Feeds.
export function currentItem(pathname) {
  return [...mainItems, ...footerItems].find((item) => isActiveItem(item, pathname))
}
