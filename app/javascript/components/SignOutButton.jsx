import { CircleUserRound } from "lucide-react"

// Devise signs out via DELETE, so submit a form with Rails' method override and CSRF token.
// Without children the button is icon-only, named by its aria-label.
export default function SignOutButton({ path, className, children }) {
  const csrfParam = document.querySelector("meta[name='csrf-param']")?.content
  const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

  return (
    <form method="post" action={path}>
      <input type="hidden" name="_method" value="delete" />
      {csrfParam && <input type="hidden" name={csrfParam} value={csrfToken} />}
      <button
        type="submit"
        className={className}
        {...(children ? {} : { "aria-label": "Sign out", title: "Sign out" })}
      >
        {children ?? <CircleUserRound className="size-5" aria-hidden="true" />}
      </button>
    </form>
  )
}
