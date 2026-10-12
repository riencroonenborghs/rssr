import { useState } from "react"
import { useNavigate } from "react-router"
import { apiRequest } from "../lib/api"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"

const inputClassName = "w-full rounded-lg border border-gray-300 bg-surface px-3 py-2 shadow-sm transition outline-none focus:border-brand focus:ring-3 focus:ring-brand/15"

// Subscribes to a feed by URL. Without a title, the server reads it from the feed. On success the
// feed opens; its entries are fetched in the background.
export default function AddFeedPage() {
  const navigate = useNavigate()
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event) => {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    setSubmitting(true)
    setError(null)

    try {
      const feed = await apiRequest("/api/subscriptions", {
        method: "POST",
        body: { url: form.get("url"), title: form.get("title") }
      })
      navigate(`/feeds/${feed.id}`)
    } catch (requestError) {
      setError(requestError.message)
      setSubmitting(false)
    }
  }

  return (
    <>
      <ListColumn>
        <ListHeader title="Add a feed" />
        <form onSubmit={handleSubmit} className="space-y-4 p-4 md:p-5">
          {error && <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">{error}</p>}

          <label className="block text-sm">
            <span className="mb-1 block font-medium">URL</span>
            <input type="url" name="url" required autoFocus placeholder="https://example.com/feed.xml" className={inputClassName} />
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
      </ListColumn>
      <DetailColumn>
        <Message>The feed's entries appear once they have been fetched.</Message>
      </DetailColumn>
    </>
  )
}
