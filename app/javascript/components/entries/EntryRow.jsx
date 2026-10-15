import { useState } from "react"
import { Link, NavLink } from "react-router"
import { formatAge, formatDateTime } from "../../lib/format"
import { useSettings } from "../../lib/settings"
import FeedAvatar from "../FeedAvatar"
import BookmarkButton from "./BookmarkButton"

// An entry in a list, linking to its details; unread entries are darker than read ones and marked
// with a dot. With showFeed, the feed's name above it links to the feed. The feed link and the
// bookmark button sit beside the entry's link, not inside it. The "regular" layout shows
// the entry's image; "compact" leaves it out and uses less space. With newTab, the details open in
// a new tab.
export default function EntryRow({ entry, to, showFeed = false, showBookmark = false, newTab = false }) {
  const { settings } = useSettings()
  const compact = settings.entryLayout === "compact"
  const muted = entry.read ? "text-gray-400" : "text-gray-500"

  return (
    <div className="relative flex items-start transition-colors has-[a.active]:bg-brand/12 has-[a:not(.active):hover]:bg-brand/6">
      <div className="flex min-w-0 flex-1 flex-col">
        {showFeed && (
          <div className={`flex min-w-0 ${compact ? "px-4 pt-2 md:px-5" : "px-4 pt-3.5 md:px-5"}`}>
            <Link
              to={`/feeds/${entry.feed.id}`}
              className={`flex min-w-0 items-center gap-1.5 rounded-sm hover:text-gray-900 hover:underline ${compact ? "text-[11px]" : "text-xs"} ${muted}`}
            >
              {!compact && <FeedAvatar title={entry.feed.title} size="sm" />}
              <span className="truncate font-medium">{entry.feed.title}</span>
            </Link>
          </div>
        )}
        <NavLink
          to={to}
          target={newTab ? "_blank" : undefined}
          className={`flex min-w-0 flex-1 gap-4 rounded-sm px-4 md:px-5 ${compact ? "pb-2" : "pb-3.5"} ${showFeed ? (compact ? "pt-0" : "pt-1") : (compact ? "pt-2" : "pt-3.5")}`}
        >
          <div className="min-w-0 flex-1">
            <p
              className={`break-words tracking-tight ${compact ? "text-sm leading-snug" : "text-[15px] leading-snug"} ${entry.read ? "text-gray-400" : "font-medium text-gray-900"}`}
            >
              {entry.title || "Untitled"}
            </p>
            <time
              dateTime={entry.published_at}
              title={formatDateTime(entry.published_at)}
              className={`mt-1 block tabular-nums ${compact ? "mt-0.5 text-[11px]" : "text-xs"} ${muted}`}
            >
              {formatAge(entry.published_at)}
            </time>
          </div>
          {!compact && entry.image_url && <Thumbnail src={entry.image_url} read={entry.read} />}
        </NavLink>
      </div>
      {showBookmark && (
        <BookmarkButton
          entry={entry}
          className={compact ? "mt-1 mr-1.5" : "mt-2.5 mr-2"}
        />
      )}
    </div>
  )
}

// Feed images are hotlinked: no referrer is sent, and broken images are hidden.
function Thumbnail({ src, read }) {
  const [failed, setFailed] = useState(false)
  if (failed) return null

  return (
    <img
      src={src}
      alt=""
      loading="lazy"
      referrerPolicy="no-referrer"
      onError={() => setFailed(true)}
      className={`h-16 w-24 shrink-0 rounded-lg object-cover ring-1 ring-black/5 ${read ? "opacity-60" : ""}`}
    />
  )
}
