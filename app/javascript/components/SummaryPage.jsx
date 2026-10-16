import { ArrowLeft, Sparkles } from "lucide-react"
import { Fragment, useState } from "react"
import { Link } from "react-router"
import { apiRequest } from "../lib/api"
import { formatAge, formatDateTime } from "../lib/format"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"

const inputClassName = "w-full rounded-lg border border-gray-300 bg-surface px-3 py-2 shadow-sm transition outline-none focus:border-brand focus:ring-3 focus:ring-brand/15"

const PERIODS = { "24h": "24 hours", week: "Week", "2weeks": "2 weeks" }

function Alert({ children }) {
  return <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">{children}</p>
}

// Turns the [n] citations in a line of the summary into links to the entries they cite.
function Cited({ text, entries }) {
  return text.split(/(\[\d+\])/).map((part, index) => {
    const entry = entries[Number(part.match(/^\[(\d+)\]$/)?.[1]) - 1]
    if (!entry) return <Fragment key={index}>{part}</Fragment>
    return (
      <Link key={index} to={`/entries/${entry.id}`} title={entry.title}
        className="mx-px rounded px-0.5 text-xs font-semibold text-brand align-super hover:bg-brand/10">
        {part}
      </Link>
    )
  })
}

// Renders the summary's plain text format: "## " headings, "- " bullets and paragraphs.
function SummaryText({ text, entries }) {
  const blocks = []
  for (const line of text.split("\n").map((line) => line.trim()).filter(Boolean)) {
    if (line.startsWith("## ")) blocks.push({ type: "heading", text: line.slice(3) })
    else if (line.startsWith("- ")) {
      const last = blocks.at(-1)
      if (last?.type === "list") last.items.push(line.slice(2))
      else blocks.push({ type: "list", items: [line.slice(2)] })
    } else blocks.push({ type: "paragraph", text: line })
  }

  return (
    <div className="space-y-4 text-[15px] leading-relaxed">
      {blocks.map((block, index) => {
        if (block.type === "heading") return <h2 key={index} className="pt-2 text-lg font-semibold tracking-tight">{block.text}</h2>
        if (block.type === "list") {
          return (
            <ul key={index} className="list-disc space-y-1.5 pl-5">
              {block.items.map((item, itemIndex) => <li key={itemIndex}><Cited text={item} entries={entries} /></li>)}
            </ul>
          )
        }
        return <p key={index}><Cited text={block.text} entries={entries} /></p>
      })}
    </div>
  )
}

function SummaryForm({ onSummarize, submitting }) {
  const [period, setPeriod] = useState("24h")

  const handleSubmit = (event) => {
    event.preventDefault()
    onSummarize({ keywords: new FormData(event.currentTarget).get("keywords"), period })
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4 p-4 md:p-5">
      <label className="block text-sm">
        <span className="mb-1 block font-medium">Keywords</span>
        <input type="text" name="keywords" required placeholder="e.g. electric cars" className={inputClassName} />
        <span className="mt-1 block text-xs text-gray-500">Posts containing all of the words, as in search.</span>
      </label>

      <fieldset className="text-sm">
        <legend className="mb-1 font-medium">Period</legend>
        <div className="grid grid-cols-3 gap-2">
          {Object.entries(PERIODS).map(([value, label]) => (
            <label key={value}
              className="cursor-pointer rounded-lg border border-gray-300 bg-surface px-3 py-2 text-center shadow-sm transition-colors hover:border-brand/40 has-[:checked]:border-brand has-[:checked]:bg-brand/6 has-[:checked]:font-medium has-[:checked]:ring-1 has-[:checked]:ring-brand">
              <input type="radio" name="period" value={value} checked={period === value} onChange={() => setPeriod(value)} className="sr-only" />
              {label}
            </label>
          ))}
        </div>
      </fieldset>

      <button type="submit" disabled={submitting}
        className="flex w-full items-center justify-center gap-2 rounded-lg bg-brand px-3 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-brand/90 disabled:opacity-50">
        <Sparkles className={`size-4 ${submitting ? "animate-pulse" : ""}`} aria-hidden="true" />
        {submitting ? "Summarizing…" : "Summarize"}
      </button>
    </form>
  )
}

function SummaryEntries({ result }) {
  return (
    <section className="border-t border-brand/10">
      <h2 className="px-4 pt-4 text-xs font-semibold tracking-wide text-gray-500 uppercase md:px-5">
        {result.entries.length < result.total
          ? `Newest ${result.entries.length} of ${result.total} posts`
          : `${result.total} ${result.total === 1 ? "post" : "posts"}`}
      </h2>
      <ol aria-label="Summarized posts" className="divide-y divide-brand/10">
        {result.entries.map((entry, index) => (
          <li key={entry.id}>
            <Link to={`/entries/${entry.id}`} className="flex gap-3 px-4 py-3 transition-colors hover:bg-brand/6 md:px-5">
              <span className="w-6 shrink-0 text-xs font-semibold text-brand">[{index + 1}]</span>
              <span className="min-w-0 flex-1">
                <span className="block truncate text-sm font-medium">{entry.title}</span>
                <span className="block truncate text-xs text-gray-500">
                  {entry.feed.title} · <time dateTime={entry.published_at} title={formatDateTime(entry.published_at)}>{formatAge(entry.published_at)}</time>
                </span>
              </span>
            </Link>
          </li>
        ))}
      </ol>
    </section>
  )
}

// Summarizes, with Claude, the posts matching keywords within a period. The summary cites the
// posts it is based on, which are listed below the form.
export default function SummaryPage() {
  const [result, setResult] = useState(null)
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  const summarize = async (params) => {
    setSubmitting(true)
    setError(null)
    try {
      setResult(await apiRequest("/api/summary", { method: "POST", body: params }))
    } catch (requestError) {
      setError(requestError.message)
    } finally {
      setSubmitting(false)
    }
  }

  const hasSummary = Boolean(result?.summary)

  return (
    <>
      <ListColumn hasSelection={hasSummary}>
        <ListHeader title="Summary" />
        <SummaryForm onSummarize={summarize} submitting={submitting} />
        {error && <div className="px-4 pb-4 md:px-5"><Alert>{error}</Alert></div>}
        {result && !hasSummary && <Message>No posts match these keywords in this period.</Message>}
        {hasSummary && <SummaryEntries result={result} />}
      </ListColumn>
      <DetailColumn hasSelection={hasSummary}>
        {submitting && !hasSummary && <Message>Reading the posts and writing a summary; this can take a minute.</Message>}
        {!submitting && !hasSummary && <Message>Enter keywords and a period to summarize matching posts.</Message>}
        {hasSummary && (
          <article aria-label="Summary" className={`mx-auto max-w-3xl px-5 py-5 md:px-10 md:py-8 ${submitting ? "opacity-50" : ""}`}>
            <button type="button" onClick={() => setResult(null)}
              className="-ml-2 mb-6 inline-flex items-center gap-1.5 rounded-full px-2 py-1 text-sm text-gray-500 transition-colors hover:bg-gray-100 hover:text-gray-900 md:hidden">
              <ArrowLeft className="size-4" aria-hidden="true" />
              New summary
            </button>
            <SummaryText text={result.summary} entries={result.entries} />
          </article>
        )}
      </DetailColumn>
    </>
  )
}
