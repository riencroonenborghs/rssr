// A feed's initial in a tinted square, standing in for its icon.
export default function FeedAvatar({ title, size = "md" }) {
  const initial = (title ?? "").replace(/^https?:\/\/(www\.)?/, "").match(/[\p{L}\p{N}]/u)?.[0]?.toUpperCase() ?? "?"
  const sizes = { sm: "size-4 rounded text-[9px]", md: "size-7 rounded-md text-xs" }

  return (
    <span
      aria-hidden="true"
      className={`inline-flex shrink-0 items-center justify-center bg-brand/15 font-semibold text-brand-fg ${sizes[size]}`}
    >
      {initial}
    </span>
  )
}
