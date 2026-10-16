import { Plus, Trash2 } from "lucide-react"
import { useState } from "react"
import { Link } from "react-router"
import { apiRequest } from "../lib/api"
import useApi from "../lib/useApi"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"
import FeedAvatar from "./FeedAvatar"

function Alert({ children }) {
  return <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">{children}</p>
}

function SubscriptionRow({ subscription, onDelete }) {
  const { feed } = subscription
  const [deleting, setDeleting] = useState(false)

  const handleDelete = async () => {
    setDeleting(true)
    try {
      await apiRequest(`/api/subscriptions/${subscription.id}`, { method: "DELETE" })
      onDelete(subscription)
    } catch {
      setDeleting(false)
    }
  }

  return (
    <li className="flex items-center gap-3 px-4 py-3 md:px-5">
      <FeedAvatar title={feed.title} />
      <div className="min-w-0 flex-1">
        <Link to={`/feeds/${feed.id}`} className="block truncate text-sm font-medium hover:text-brand">{feed.title}</Link>
        <p className="truncate text-xs text-gray-500">{feed.url}</p>
        {feed.error && <p className="truncate text-xs text-red-700 dark:text-red-300" title={feed.error}>{feed.error}</p>}
      </div>
      <button type="button" onClick={handleDelete} disabled={deleting} aria-label={`Unsubscribe from ${feed.title}`} title="Unsubscribe"
        className="rounded-lg p-2 text-gray-500 transition-colors hover:bg-red-50 hover:text-red-700 disabled:opacity-50 dark:hover:bg-red-950 dark:hover:text-red-300">
        <Trash2 className="size-4" aria-hidden="true" />
      </button>
    </li>
  )
}

// The feeds the user is subscribed to, which they can unsubscribe from.
export default function SubscriptionsPage() {
  const { data: subscriptions, error, loading, setData } = useApi("/api/subscriptions")

  const removeSubscription = (subscription) =>
    setData((current) => current.filter((other) => other.id !== subscription.id))

  return (
    <>
      <ListColumn>
        <ListHeader title="Subscriptions" />
        <div className="p-4 md:p-5">
          <Link to="/subscriptions/new"
            className="flex w-full items-center justify-center gap-2 rounded-lg bg-brand px-3 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-brand/90">
            <Plus className="size-4" aria-hidden="true" />
            Add a feed
          </Link>
        </div>

        <div className="border-t border-brand/10">
          {loading && <Message>Loading…</Message>}
          {error && <div className="p-4 md:p-5"><Alert>{error.message}</Alert></div>}
          {subscriptions?.length === 0 && <Message>You have no subscriptions yet.</Message>}
          {subscriptions?.length > 0 && (
            <ul aria-label="Subscriptions" className="divide-y divide-brand/10">
              {subscriptions.map((subscription) =>
                <SubscriptionRow key={subscription.id} subscription={subscription} onDelete={removeSubscription} />)}
            </ul>
          )}
        </div>
      </ListColumn>
      <DetailColumn>
        <Message>
          Unsubscribing removes a feed and its entries from your dashboard, feeds and search.
          Your bookmarks of its entries are kept.
        </Message>
      </DetailColumn>
    </>
  )
}
