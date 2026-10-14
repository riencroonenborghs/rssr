import { ArrowLeft } from "lucide-react"
import { Link, useOutletContext, useParams } from "react-router"
import useEntriesPages from "../../lib/useEntriesPages"
import { Message } from "../Columns"
import FeedAvatar from "../FeedAvatar"
import EntryRow from "../entries/EntryRow"
import LoadMoreButton from "../entries/LoadMoreButton"

// A feed's entries, a page at a time. They fill column 3, so an entry's details open in a new tab; reading it there
// still updates this list.
export default function EntryList({ session }) {
  const { feedId } = useParams()
  const { feeds } = useOutletContext()
  const feed = feeds?.find((candidate) => String(candidate.id) === feedId)
  const { entries, nextPage, loading, error, loadMore } = useEntriesPages(`/api/feeds/${feedId}/entries`)
  const isMobile = window.matchMedia("(max-width: 768px)").matches;

  return (
    <>
      <header className="sticky top-0 z-10 flex items-center gap-2 border-b border-gray-200 bg-surface/85 px-4 py-3 backdrop-blur md:px-5">
        {/* The feed list is beside the entries from md up; below that it needs a way back. */}
        <Link to="/feeds" aria-label="Back to feeds" className="-ml-1 rounded-full p-1.5 text-gray-600 transition-colors hover:bg-gray-100 md:hidden">
          <ArrowLeft className="size-5" aria-hidden="true" />
        </Link>
        {feed && <FeedAvatar title={feed.title} />}
        <h2 className="truncate text-base font-semibold tracking-tight">{feed?.title ?? "Entries"}</h2>
      </header>

      {!loading && !error && entries.length === 0 && <Message>This feed has no entries.</Message>}
      <ul className="divide-y divide-gray-100 py-1">
        {entries.map((entry) => (
          <li key={entry.id}>
            <EntryRow entry={entry} to={`/feeds/${feedId}/entries/${entry.id}`} showBookmark={session.signedIn} newTab={isMobile} />
          </li>
        ))}
      </ul>
      {loading && <Message>Loading…</Message>}
      {error && <Message>Could not load entries: {error.message}</Message>}
      {nextPage && !loading && <LoadMoreButton onClick={loadMore} />}
    </>
  )
}
