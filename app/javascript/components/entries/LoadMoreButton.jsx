export default function LoadMoreButton({ onClick }) {
  return (
    <div className="px-4 py-5 text-center">
      <button
        type="button"
        onClick={onClick}
        className="rounded-full border border-brand/30 bg-surface px-5 py-2 text-sm font-medium text-brand-fg shadow-sm transition-colors hover:bg-brand/8"
      >
        Load more
      </button>
    </div>
  )
}
