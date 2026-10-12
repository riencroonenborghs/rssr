import { Bookmark, Funnel, LayoutDashboard, Plus, Rss, Search, Settings } from "lucide-react"

// The app's sections, shown in the desktop sidebar and the mobile menu. A section is active on
// its path and the paths below it; the dashboard's entries live under /entries.
export const mainItems = [
  { to: "/", label: "Dashboard", icon: LayoutDashboard, paths: [ "/entries" ] },
  { to: "/feeds", label: "Feeds", icon: Rss },
  { to: "/bookmarks", label: "Bookmarks", icon: Bookmark },
  { to: "/search", label: "Search", icon: Search },
  { to: "/subscriptions/new", label: "Add a feed", icon: Plus }
]

// Shown at the bottom of the navigation.
export const footerItems = [
  { to: "/filters", label: "Filters", icon: Funnel },
  { to: "/settings", label: "Settings", icon: Settings }
]

const isUnder = (pathname, path) => pathname === path || pathname.startsWith(`${path}/`)

export function isActiveItem(item, pathname) {
  if (item.to === "/") return pathname === "/" || (item.paths ?? []).some((path) => isUnder(pathname, path))
  return isUnder(pathname, item.to)
}

// The section the path belongs to, e.g. "/feeds/1/entries/2" is in Feeds.
export function currentItem(pathname) {
  return [...mainItems, ...footerItems].find((item) => isActiveItem(item, pathname))
}
