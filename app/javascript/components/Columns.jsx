// The two content columns next to the sidebar: a list (column 2) and its details (column 3).
// On small screens only one is shown: the details when something is selected, else the list.
export function ListColumn({ hasSelection = false, children }) {
  return (
    <main className={`min-h-0 flex-1 overflow-y-auto bg-brand/4 md:block md:border-r md:border-brand/15 ${hasSelection ? "hidden" : ""}`}>
      {children}
    </main>
  )
}

export function DetailColumn({ hasSelection = false, children }) {
  return (
    <section className={`min-h-0 flex-1 overflow-y-auto md:block ${hasSelection ? "" : "hidden"}`}>
      {children}
    </section>
  )
}

// Column 2's title on desktop; phones show it in the top bar instead.
export function ListHeader({ title }) {
  return (
    <div className="sticky top-0 z-10 hidden border-b border-brand/10 bg-surface/85 px-4 py-3.5 backdrop-blur md:block md:px-5">
      <h1 className="text-[15px] font-semibold tracking-tight">{title}</h1>
    </div>
  )
}

export function Message({ children }) {
  return <p className="px-6 py-8 text-center text-sm text-gray-500">{children}</p>
}
