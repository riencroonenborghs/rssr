import { Trash2 } from "lucide-react"
import { useState } from "react"
import { apiRequest } from "../lib/api"
import useApi from "../lib/useApi"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"

const inputClassName = "w-full rounded-lg border border-gray-300 bg-surface px-3 py-2 shadow-sm transition outline-none focus:border-brand focus:ring-3 focus:ring-brand/15"

const KINDS = {
  keyword: { label: "Keywords", placeholder: "e.g. sponsored post" },
  regexp: { label: "Regular expression", placeholder: "e.g. \\bgiveaway\\b" }
}

function Alert({ children }) {
  return <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">{children}</p>
}

function FilterForm({ onCreate }) {
  const [kind, setKind] = useState("keyword")
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (event) => {
    event.preventDefault()
    const form = event.currentTarget
    setSubmitting(true)
    setError(null)

    try {
      const filter = await apiRequest("/api/filters", {
        method: "POST",
        body: { kind, value: new FormData(form).get("value") }
      })
      onCreate(filter)
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
        <span className="mb-1 block font-medium">Type</span>
        <select name="kind" value={kind} onChange={(event) => setKind(event.target.value)} className={inputClassName}>
          {Object.entries(KINDS).map(([value, { label }]) => <option key={value} value={value}>{label}</option>)}
        </select>
      </label>

      <label className="block text-sm">
        <span className="mb-1 block font-medium">Value</span>
        <input type="text" name="value" required placeholder={KINDS[kind].placeholder} className={inputClassName} />
      </label>

      <button type="submit" disabled={submitting}
        className="w-full rounded-lg bg-brand px-3 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-brand/90 disabled:opacity-50">
        {submitting ? "Adding…" : "Add filter"}
      </button>
    </form>
  )
}

function FilterRow({ filter, onDelete }) {
  const [deleting, setDeleting] = useState(false)

  const handleDelete = async () => {
    setDeleting(true)
    try {
      await apiRequest(`/api/filters/${filter.id}`, { method: "DELETE" })
      onDelete(filter)
    } catch {
      setDeleting(false)
    }
  }

  return (
    <li className="flex items-center gap-3 px-4 py-3 md:px-5">
      <div className="min-w-0 flex-1">
        <p className={`truncate text-sm ${filter.kind === "regexp" ? "font-mono" : "font-medium"}`}>{filter.value}</p>
        <p className="text-xs text-gray-500">{KINDS[filter.kind].label}</p>
      </div>
      <button type="button" onClick={handleDelete} disabled={deleting} aria-label={`Delete filter ${filter.value}`} title="Delete"
        className="rounded-lg p-2 text-gray-500 transition-colors hover:bg-red-50 hover:text-red-700 disabled:opacity-50 dark:hover:bg-red-950 dark:hover:text-red-300">
        <Trash2 className="size-4" aria-hidden="true" />
      </button>
    </li>
  )
}

// The user's filters, which hide matching entries from the dashboard, feeds and search.
export default function FiltersPage() {
  const { data: filters, error, loading, setData } = useApi("/api/filters")

  const addFilter = (filter) => setData((current) =>
    [...current, filter].sort((a, b) => a.kind.localeCompare(b.kind) || a.value.localeCompare(b.value)))
  const removeFilter = (filter) => setData((current) => current.filter((other) => other.id !== filter.id))

  return (
    <>
      <ListColumn>
        <ListHeader title="Filters" />
        <FilterForm onCreate={addFilter} />

        <div className="border-t border-brand/10">
          {loading && <Message>Loading…</Message>}
          {error && <div className="p-4 md:p-5"><Alert>{error.message}</Alert></div>}
          {filters?.length === 0 && <Message>You have no filters yet.</Message>}
          {filters?.length > 0 && (
            <ul aria-label="Filters" className="divide-y divide-brand/10">
              {filters.map((filter) => <FilterRow key={filter.id} filter={filter} onDelete={removeFilter} />)}
            </ul>
          )}
        </div>
      </ListColumn>
      <DetailColumn>
        <Message>
          Filters hide entries whose title or summary match them. A keywords filter matches entries
          containing all of its words; a regular expression filter matches using a Ruby regular expression.
        </Message>
      </DetailColumn>
    </>
  )
}
