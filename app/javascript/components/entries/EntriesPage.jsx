import { Outlet, useMatch } from "react-router"
import useEntriesPages from "../../lib/useEntriesPages"
import useMarkRead from "../../lib/useMarkRead"
import { DetailColumn, ListColumn, ListHeader, Message } from "../Columns"
import EntryRow from "./EntryRow"
import LoadMoreButton from "./LoadMoreButton"

// Column 2 lists entries from an endpoint returning { entries, next_page }, newest first, with a
// "Load more" button; column 3 shows an entry's details at `${basePath}/entries/:entryId`.
// Without an apiPath nothing is loaded (e.g. before a search); header goes above the list.
export default function EntriesPage({ session, apiPath, basePath, emptyMessage, header, title }) {
  const prefix = basePath === "/" ? "" : basePath
  const hasSelection = Boolean(useMatch(`${prefix}/entries/:entryId`))
  const { entries, nextPage, loading, error, loadMore } = useEntriesPages(apiPath)
  const markRead = useMarkRead(session)
  const isMobile = window.matchMedia("(max-width: 768px)").matches;

  return (
    <>
      <ListColumn hasSelection={hasSelection}>
        {title && <ListHeader title={title} />}
        {header}
        {!loading && !error && entries.length === 0 && <Message>{emptyMessage}</Message>}
        <ul className="divide-y divide-brand/10">
          {entries.map((entry) => (
            <li key={entry.id}>
              <EntryRow entry={entry} to={`${prefix}/entries/${entry.id}`} showFeed newTab={isMobile} showBookmark={session.signedIn} />
            </li>
          ))}
        </ul>
        {loading && <Message>Loading…</Message>}
        {error && <Message>Could not load entries: {error.message}</Message>}
        {nextPage && !loading && <LoadMoreButton onClick={loadMore} />}
      </ListColumn>
      <DetailColumn hasSelection={hasSelection}>
        <Outlet context={{ markRead }} />
      </DetailColumn>
    </>
  )
}
