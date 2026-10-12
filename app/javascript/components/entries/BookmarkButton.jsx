import { Bookmark } from "lucide-react"
import { useState } from "react"
import { setBookmarked } from "../../lib/bookmarks"

// Toggles the signed in user's bookmark on an entry.
export default function BookmarkButton({ entry, className = "" }) {
  const [saving, setSaving] = useState(false)
  const label = entry.bookmarked ? "Remove bookmark" : "Bookmark"

  const toggle = async () => {
    setSaving(true)
    try {
      await setBookmarked(entry.id, !entry.bookmarked)
    } catch {
      window.alert("Could not update the bookmark. Please try again.")
    } finally {
      setSaving(false)
    }
  }

  return (
    <button
      type="button"
      onClick={toggle}
      disabled={saving}
      aria-label={label}
      aria-pressed={entry.bookmarked}
      title={label}
      className={`shrink-0 rounded-full p-1.5 transition-colors hover:bg-gray-900/5 disabled:opacity-50 dark:hover:bg-white/10 ${className}`}
    >
      <Bookmark
        className={`size-4 transition-colors ${entry.bookmarked ? "fill-current text-amber-500" : "text-gray-400 hover:text-gray-600"}`}
        aria-hidden="true"
      />
    </button>
  )
}
