import { Search } from "lucide-react"
import { useEffect, useState } from "react"
import { useSearchParams } from "react-router"
import EntriesPage from "./entries/EntriesPage"

const DEBOUNCE_MS = 300

// Searches entry titles and summaries. The query is kept in the URL (?q=), updated shortly after
// typing stops, so results can be reloaded and shared.
export default function SearchPage({ session }) {
  const [searchParams, setSearchParams] = useSearchParams()
  const query = searchParams.get("q") ?? ""
  const [input, setInput] = useState(query)

  useEffect(() => {
    const trimmed = input.trim()
    if (trimmed === query) return
    const timeout = setTimeout(() => setSearchParams(trimmed ? { q: trimmed } : {}, { replace: true }), DEBOUNCE_MS)
    return () => clearTimeout(timeout)
  }, [input, query, setSearchParams])

  const header = (
    <form role="search" onSubmit={(event) => event.preventDefault()} className="sticky top-0 z-10 border-b border-brand/10 bg-surface/85 p-3 backdrop-blur md:px-4">
      <label className="flex items-center gap-2.5 rounded-full border border-gray-200 bg-surface px-4 py-2 shadow-sm transition focus-within:border-brand focus-within:ring-3 focus-within:ring-brand/15">
        <Search className="size-4 shrink-0 text-gray-500" aria-hidden="true" />
        <input
          type="search"
          value={input}
          onChange={(event) => setInput(event.target.value)}
          placeholder="Search titles and summaries"
          aria-label="Search titles and summaries"
          autoFocus
          className="min-w-0 flex-1 bg-transparent text-sm outline-none [&::-webkit-search-cancel-button]:opacity-50 [&::-webkit-search-cancel-button]:grayscale"
        />
      </label>
    </form>
  )

  return (
    <EntriesPage
      session={session}
      apiPath={query ? `/api/search?q=${encodeURIComponent(query)}` : null}
      basePath="/search"
      emptyMessage={query ? "No entries match your search." : "Type to search entry titles and summaries."}
      header={header}
    />
  )
}
