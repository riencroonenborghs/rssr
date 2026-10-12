import { ArrowLeft, ExternalLink } from "lucide-react"
import { useCallback, useEffect } from "react"
import { Link, useOutletContext, useParams } from "react-router"
import { formatDateTime } from "../../lib/format"
import { useBookmarkChanges, withBookmark } from "../../lib/bookmarks"
import useApi from "../../lib/useApi"
import { Message } from "../Columns"
import FeedAvatar from "../FeedAvatar"
import BookmarkButton from "./BookmarkButton"

// An entry's details. Opening an entry marks it as read. The back link goes to backTo, or to the
// entry's feed by default.
export default function EntryDetail({ session, backTo, backLabel }) {
  const { entryId } = useParams()
  const { markRead } = useOutletContext()
  const { data: entry, error, loading, setData } = useApi(`/api/entries/${entryId}`)

  useBookmarkChanges(useCallback((change) => setData((current) => withBookmark(current, change)), [setData]))

  useEffect(() => {
    if (entry) markRead(entry).catch(() => {})
  }, [entry, markRead])

  return (
    <article className="mx-auto max-w-3xl px-5 py-5 md:px-10 md:py-8">
      {(backTo || entry) && (
        <Link
          to={backTo ?? `/feeds/${entry.feed.id}`}
          className="-ml-2 mb-6 inline-flex items-center gap-1.5 rounded-full px-2 py-1 text-sm text-gray-500 transition-colors hover:bg-gray-100 hover:text-gray-900"
        >
          <ArrowLeft className="size-4" aria-hidden="true" />
          {backLabel ?? entry.feed.title}
        </Link>
      )}

      {loading && <Message>Loading…</Message>}
      {error && <Message>Could not load the entry: {error.message}</Message>}
      {entry && (
        <>
          <header className="mb-8 border-b border-gray-200 pb-6">
            <p className="flex min-w-0 items-center gap-2 text-sm text-gray-500">
              <FeedAvatar title={entry.feed.title} size="sm" />
              <span className="truncate font-medium text-gray-700">{entry.feed.title}</span>
              <span aria-hidden="true">·</span>
              <time dateTime={entry.published_at} className="shrink-0">{formatDateTime(entry.published_at)}</time>
            </p>
            <h1 className="mt-3 break-words text-2xl font-bold leading-tight tracking-tight text-gray-900 md:text-[2rem]">
              {entry.title || "Untitled"}
            </h1>
            <div className="mt-5 flex flex-wrap items-center gap-2">
              {entry.url && (
                <a
                  href={entry.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="inline-flex items-center gap-1.5 rounded-full bg-brand px-3.5 py-1.5 text-sm font-medium text-white shadow-sm transition-colors hover:bg-brand/90"
                >
                  Open original <ExternalLink className="size-3.5" aria-hidden="true" />
                </a>
              )}
              {session.signedIn && <BookmarkButton entry={entry} className="border border-gray-200" />}
            </div>
          </header>

          {/* summary_html is sanitized by the server. */}
          <div
            className="entry-content"
            dangerouslySetInnerHTML={{ __html: entry.summary_html || "" }}
          />
        </>
      )}
    </article>
  )
}
