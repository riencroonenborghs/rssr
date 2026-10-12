import { X } from "lucide-react"
import { useEffect, useRef, useState } from "react"

// Signs in through Devise's JSON session endpoint. On success the page reloads: Devise starts a
// new session on sign in, which invalidates the page's CSRF token and changes the signed-in state.
export default function SignInModal({ open, onClose, path }) {
  const dialogRef = useRef(null)
  const [error, setError] = useState(null)
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    const dialog = dialogRef.current
    if (open && !dialog.open) dialog.showModal()
    if (!open && dialog.open) dialog.close()
  }, [open])

  const handleClose = () => {
    setError(null)
    onClose()
  }

  const handleSubmit = async (event) => {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    setSubmitting(true)
    setError(null)

    try {
      const response = await fetch(path, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
        },
        body: JSON.stringify({
          user: {
            email: form.get("email"),
            password: form.get("password"),
            remember_me: form.get("remember_me") ? "1" : "0"
          }
        })
      })

      if (response.ok) {
        window.location.reload()
        return
      }

      const body = await response.json().catch(() => ({}))
      setError(body.error || "Signing in failed. Please try again.")
    } catch {
      setError("Signing in failed. Please check your connection and try again.")
    }
    setSubmitting(false)
  }

  return (
    <dialog
      ref={dialogRef}
      onClose={handleClose}
      aria-labelledby="sign-in-title"
      className="m-auto w-[calc(100%-2rem)] max-w-sm rounded-2xl bg-surface p-6 text-gray-900 shadow-2xl ring-1 ring-black/5 backdrop:bg-black/40 backdrop:backdrop-blur-sm"
    >
      <div className="mb-4 flex items-center justify-between">
        <h2 id="sign-in-title" className="text-xl font-semibold tracking-tight">Sign in</h2>
        <button type="button" onClick={handleClose} aria-label="Close" className="rounded-full p-1.5 text-gray-500 transition-colors hover:bg-gray-100">
          <X className="size-5" aria-hidden="true" />
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        {error && <p role="alert" className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950 dark:text-red-300">{error}</p>}

        <label className="block text-sm">
          <span className="mb-1 block font-medium">Email</span>
          <input type="email" name="email" required autoFocus autoComplete="email"
            className="w-full rounded-lg border border-gray-300 bg-surface px-3 py-2 shadow-sm transition outline-none focus:border-brand focus:ring-3 focus:ring-brand/15" />
        </label>

        <label className="block text-sm">
          <span className="mb-1 block font-medium">Password</span>
          <input type="password" name="password" required autoComplete="current-password"
            className="w-full rounded-lg border border-gray-300 bg-surface px-3 py-2 shadow-sm transition outline-none focus:border-brand focus:ring-3 focus:ring-brand/15" />
        </label>

        <label className="flex items-center gap-2 text-sm">
          <input type="checkbox" name="remember_me" />
          Remember me
        </label>

        <button type="submit" disabled={submitting}
          className="w-full rounded-lg bg-brand px-3 py-2.5 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-brand/90 disabled:opacity-50">
          {submitting ? "Signing in…" : "Sign in"}
        </button>
      </form>
    </dialog>
  )
}
