import { useRef } from "react"
import { LIST_WIDTH } from "../lib/settings"

const SIDEBAR_WIDTH = 64 // 4rem
const MIN_DETAIL_WIDTH = 320 // keep room for column 3
const KEYBOARD_STEP = 16

export function clampListWidth(width) {
  const max = Math.min(LIST_WIDTH.max, window.innerWidth - SIDEBAR_WIDTH - MIN_DETAIL_WIDTH)
  return Math.round(Math.min(Math.max(width, LIST_WIDTH.min), Math.max(max, LIST_WIDTH.min)))
}

// A drag handle on the right edge of column 2 (from md up). onResize is called while resizing,
// onResizeEnd once with the final width. Double click resets; arrow keys resize too.
export default function ColumnResizer({ width, onResize, onResizeEnd }) {
  const dragging = useRef(false)

  const handlePointerDown = (event) => {
    event.preventDefault()
    event.currentTarget.setPointerCapture(event.pointerId)
    dragging.current = true
    document.body.classList.add("cursor-col-resize", "select-none")
  }

  const widthAt = (event) => clampListWidth(event.clientX - SIDEBAR_WIDTH)

  const handlePointerMove = (event) => {
    if (dragging.current) onResize(widthAt(event))
  }

  const handlePointerUp = (event) => {
    if (!dragging.current) return
    dragging.current = false
    document.body.classList.remove("cursor-col-resize", "select-none")
    onResizeEnd(widthAt(event))
  }

  const handleKeyDown = (event) => {
    const step = { ArrowLeft: -KEYBOARD_STEP, ArrowRight: KEYBOARD_STEP }[event.key]
    if (!step) return
    event.preventDefault()
    onResizeEnd(clampListWidth(width + step))
  }

  return (
    <div
      role="separator"
      aria-orientation="vertical"
      aria-label="Resize list"
      aria-valuenow={width}
      aria-valuemin={LIST_WIDTH.min}
      aria-valuemax={LIST_WIDTH.max}
      tabIndex={0}
      onPointerDown={handlePointerDown}
      onPointerMove={handlePointerMove}
      onPointerUp={handlePointerUp}
      onPointerCancel={handlePointerUp}
      onDoubleClick={() => onResizeEnd(clampListWidth(LIST_WIDTH.default))}
      onKeyDown={handleKeyDown}
      style={{ left: SIDEBAR_WIDTH + width - 3 }}
      className="absolute inset-y-0 z-10 hidden w-1.5 cursor-col-resize outline-none hover:bg-brand/30 focus-visible:bg-brand/50 active:bg-brand/50 md:block"
    />
  )
}
