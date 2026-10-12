const dateTimeFormat = new Intl.DateTimeFormat(undefined, { dateStyle: "medium", timeStyle: "short" })
const shortDateFormat = new Intl.DateTimeFormat(undefined, { day: "numeric", month: "short" })

export const formatDateTime = (iso) => dateTimeFormat.format(new Date(iso))

// A compact age for lists, e.g. "now", "5m", "3h", "2d", then the date (e.g. "12 Oct").
export function formatAge(iso, now = Date.now()) {
  const minutes = Math.floor((now - new Date(iso).getTime()) / 60000)
  if (minutes < 1) return "now"
  if (minutes < 60) return `${minutes}m`
  if (minutes < 24 * 60) return `${Math.floor(minutes / 60)}h`
  if (minutes < 7 * 24 * 60) return `${Math.floor(minutes / (24 * 60))}d`
  return shortDateFormat.format(new Date(iso))
}
