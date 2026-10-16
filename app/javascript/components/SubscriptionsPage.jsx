import { RefreshCw, Trash2 } from "lucide-react"
import { useState } from "react"
import { Link } from "react-router"
import { apiRequest } from "../lib/api"
import { formatAge, formatDateTime } from "../lib/format"
import useApi from "../lib/useApi"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"
import FeedAvatar from "./FeedAvatar"

function Alert({ children }) {
  return <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">{children}</p>
}

// Feeds reloaded at the same time by "Reload all".
const RELOAD_CONCURRENCY = 4

const inputClassName = "w-full rounded-lg border border-gray-300 bg-surface px-3 py-2 shadow-sm transition outline-none focus:border-brand focus:ring-3 focus:ring-brand/15"

const byTitle = (a, b) => a.feed.title.localeCompare(b.feed.title, undefined, { sensitivity: "base" })

const iconButtonClassName = "rounded-lg p-2 text-gray-500 transition-colors disabled:opacity-50"

// Subscribes to a feed by URL. Without a title, the server reads it from the feed; its entries
// are fetched in the background.
function SubscriptionForm({ onCreate }) {
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event) => {
    event.preventDefault()
    const form = event.currentTarget
    const data = new FormData(form)
    setSubmitting(true)
    setError(null)

    try {
      const subscription = await apiRequest("/api/subscriptions", {
        method: "POST",
        body: { url: data.get("url"), title: data.get("title") }
      })
      onCreate(subscription)
      form.reset()
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4 p-4 md:p-5">
      {error && <Alert>{error}</Alert>}

      <label className="block text-sm">
        <span className="mb-1 block font-medium">URL</span>
        <input type="url" name="url" required placeholder="https://example.com/feed.xml" className={inputClassName} />
      </label>

      <label className="block text-sm">
        <span className="mb-1 block font-medium">Title <span className="font-normal text-gray-500">(optional)</span></span>
        <input type="text" name="title" className={inputClassName} />
        <span className="mt-1 block text-xs text-gray-500">Leave empty to use the feed's own title.</span>
      </label>

      <button type="submit" disabled={submitting}
        className="w-full rounded-lg bg-brand px-3 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-brand/90 disabled:opacity-50">
        {submitting ? "Adding…" : "Add feed"}
      </button>
    </form>
  )
}

function SubscriptionRow({ subscription, reloading, onReload, onDelete }) {
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
      {feed.last_fetched_at && (
        <time dateTime={feed.last_fetched_at} title={`Fetched ${formatDateTime(feed.last_fetched_at)}`} className="shrink-0 text-xs text-gray-500">
          {formatAge(feed.last_fetched_at)}
        </time>
      )}
      <button type="button" onClick={() => onReload(subscription)} disabled={reloading} aria-label={`Reload ${feed.title}`} title="Reload"
        className={`${iconButtonClassName} hover:bg-brand/10 hover:text-brand`}>
        <RefreshCw className={`size-4 ${reloading ? "animate-spin" : ""}`} aria-hidden="true" />
      </button>
      <button type="button" onClick={handleDelete} disabled={deleting} aria-label={`Unsubscribe from ${feed.title}`} title="Unsubscribe"
        className={`${iconButtonClassName} hover:bg-red-50 hover:text-red-700 dark:hover:bg-red-950 dark:hover:text-red-300`}>
        <Trash2 className="size-4" aria-hidden="true" />
      </button>
    </li>
  )
}

// The feeds the user is subscribed to, which they can add to, reload and unsubscribe from.
export default function SubscriptionsPage() {
  const { data: subscriptions, error, loading, setData } = useApi("/api/subscriptions")
  const [reloadingIds, setReloadingIds] = useState(() => new Set())
  const [reloadingAll, setReloadingAll] = useState(false)

  const setReloading = (subscription, reloading) => setReloadingIds((current) => {
    const next = new Set(current)
    reloading ? next.add(subscription.id) : next.delete(subscription.id)
    return next
  })

  // Adding a feed already subscribed to returns its existing subscription.
  const addSubscription = (subscription) => setData((current) =>
    [...current.filter((other) => other.id !== subscription.id), subscription].sort(byTitle))

  // A failed request leaves the row showing the feed as it was.
  const reload = async (subscription) => {
    setReloading(subscription, true)
    try {
      const reloaded = await apiRequest(`/api/subscriptions/${subscription.id}/reload`, { method: "POST" })
      setData((current) => current.map((other) => other.id === reloaded.id ? reloaded : other))
    } catch {
      // Nothing to update.
    } finally {
      setReloading(subscription, false)
    }
  }

  // Reloads every feed, a few at a time, each row updating as its feed finishes.
  const reloadAll = async () => {
    setReloadingAll(true)
    const queue = subscriptions.filter((subscription) => !reloadingIds.has(subscription.id))
    const worker = async () => {
      while (queue.length > 0) await reload(queue.shift())
    }
    await Promise.all(Array.from({ length: RELOAD_CONCURRENCY }, worker))
    setReloadingAll(false)
  }

  const removeSubscription = (subscription) =>
    setData((current) => current.filter((other) => other.id !== subscription.id))

  return (
    <>
      <ListColumn>
        <ListHeader title="Subscriptions" />
        <SubscriptionForm onCreate={addSubscription} />

        <div className="border-t border-brand/10 px-4 pt-4 md:px-5">
          <button type="button" onClick={reloadAll} disabled={reloadingAll || !subscriptions?.length}
            className="flex w-full items-center justify-center gap-2 rounded-lg border border-brand/30 bg-surface px-3 py-2.5 text-sm font-semibold text-brand shadow-sm transition-colors hover:bg-brand/10 disabled:opacity-50">
            <RefreshCw className={`size-4 ${reloadingAll ? "animate-spin" : ""}`} aria-hidden="true" />
            {reloadingAll ? "Reloading…" : "Reload all"}
          </button>
        </div>

        <div>
          {loading && <Message>Loading…</Message>}
          {error && <div className="p-4 md:p-5"><Alert>{error.message}</Alert></div>}
          {subscriptions?.length === 0 && <Message>You have no subscriptions yet.</Message>}
          {subscriptions?.length > 0 && (
            <ul aria-label="Subscriptions" className="divide-y divide-brand/10">
              {subscriptions.map((subscription) =>
                <SubscriptionRow key={subscription.id} subscription={subscription}
                  reloading={reloadingIds.has(subscription.id)} onReload={reload} onDelete={removeSubscription} />)}
            </ul>
          )}
        </div>
      </ListColumn>
      <DetailColumn>
        <Message>
          A new feed's entries appear once they have been fetched.
          Reloading fetches a feed's new entries now rather than at the next scheduled fetch.
          Unsubscribing removes a feed and its entries from your dashboard, feeds and search.
          Your bookmarks of its entries are kept.
        </Message>
      </DetailColumn>
    </>
  )
}
