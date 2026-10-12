import { useEffect } from "react"

// Announces changes to entries (read, bookmark) to every view in this tab and in other tabs of the
// app, e.g. a feed's list in one tab while its entry is read in another.
const target = new EventTarget()
const channel = typeof BroadcastChannel === "undefined" ? null : new BroadcastChannel("rssreader:entries")

channel?.addEventListener("message", ({ data }) => {
  target.dispatchEvent(new CustomEvent(data.type, { detail: data.detail }))
})

export function publish(type, detail) {
  target.dispatchEvent(new CustomEvent(type, { detail }))
  channel?.postMessage({ type, detail })
}

// Calls handler(detail) for each event of the type, from this tab or another.
export function useEntryEvent(type, handler) {
  useEffect(() => {
    const listener = (event) => handler(event.detail)
    target.addEventListener(type, listener)
    return () => target.removeEventListener(type, listener)
  }, [type, handler])
}
