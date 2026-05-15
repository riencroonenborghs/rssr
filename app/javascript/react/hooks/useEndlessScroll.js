import { useEffect, useRef } from "react"

export function useEndlessScroll(onLoadMore, enabled) {
  const ref = useRef(null)

  useEffect(() => {
    const el = ref.current
    if (!el || !enabled) return

    function onScroll() {
      if (el.scrollTop + el.clientHeight >= el.scrollHeight - 100) {
        onLoadMore()
      }
    }

    el.addEventListener("scroll", onScroll)
    return () => el.removeEventListener("scroll", onScroll)
  }, [onLoadMore, enabled])

  return ref
}
