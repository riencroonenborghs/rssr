import { useCallback, useEffect, useRef } from "react"
import { NavLink, Outlet, useMatch } from "react-router"
import useApi from "../../lib/useApi"
import useMarkRead, { useReadChanges } from "../../lib/useMarkRead"
import { DetailColumn, ListColumn, ListHeader, Message } from "../Columns"
import FeedAvatar from "../FeedAvatar"

const feedLinkClassName = ({ isActive }) =>
  `flex items-center gap-3 rounded-lg px-2.5 py-2 text-sm transition-colors ${isActive ? "bg-brand/12 font-medium text-gray-900" : "text-gray-700 hover:bg-brand/6"}`

// Column 2 lists the feeds with unread counts; column 3 shows the selected feed's entries or an
// entry's details. Signed in, these are the user's subscriptions; signed out, all feeds.
export default function FeedsPage({ session }) {
  const selectedFeedId = useMatch("/feeds/:feedId/*")?.params.feedId
  const hasSelection = Boolean(selectedFeedId)
  const { data: feeds, error, loading, setData: setFeeds } = useApi("/api/feeds")
  const markRead = useMarkRead(session)
  const listRef = useRef(null)
  const feedsLoaded = Boolean(feeds)

  // Opening a feed from elsewhere (an entry's feed name, adding a feed, a reload) scrolls the
  // list to it; one already in view stays put.
  useEffect(() => {
    if (!feedsLoaded || !selectedFeedId) return
    listRef.current?.querySelector(`[data-feed-id="${selectedFeedId}"]`)?.scrollIntoView({ block: "nearest" })
  }, [feedsLoaded, selectedFeedId])

  // Entries may be read here or in another tab (entries open in a new tab from the feed's list).
  useReadChanges(useCallback(({ feedId }) => {
    setFeeds((current) => current?.map((feed) =>
      feed.id === feedId ? { ...feed, unread_count: Math.max(0, feed.unread_count - 1) } : feed
    ))
  }, [setFeeds]))

  return (
    <>
      <ListColumn hasSelection={hasSelection}>
        <ListHeader title="Feeds" />
        {loading && <Message>Loading…</Message>}
        {error && <Message>Could not load feeds: {error.message}</Message>}
        {feeds?.length === 0 && <Message>{session.signedIn ? "You are not subscribed to any feeds yet." : "There are no feeds yet."}</Message>}
        <ul ref={listRef} className="space-y-0.5 p-2">
          {feeds?.map((feed) => (
            <li key={feed.id} data-feed-id={feed.id} className="scroll-mt-14 scroll-mb-2">
              <NavLink to={`/feeds/${feed.id}`} className={feedLinkClassName} title={feed.url}>
                <FeedAvatar title={feed.title} />
                <span className="min-w-0 flex-1 truncate">{feed.title}</span>
                {feed.unread_count > 0 && (
                  <span className="shrink-0 rounded-full bg-brand/15 px-2 py-0.5 text-xs font-semibold tabular-nums text-brand-fg">
                    {feed.unread_count}
                  </span>
                )}
              </NavLink>
            </li>
          ))}
        </ul>
      </ListColumn>
      <DetailColumn hasSelection={hasSelection}>
        <Outlet context={{ feeds, markRead }} />
      </DetailColumn>
    </>
  )
}
