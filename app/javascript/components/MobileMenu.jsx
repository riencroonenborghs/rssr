import { LogIn, CircleUserRound, ListChecks, Menu, X, ChevronRight } from "lucide-react"
import { useEffect, useRef, useState } from "react"
import { Link, useLocation } from "react-router"
import { currentItem, footerItems, isActiveItem, mainItems } from "./navigation"
import SignOutButton from "./SignOutButton"

const menuLinkClassName = ({ isActive }) =>
  `flex w-full items-center gap-3 rounded-xl px-3 py-2.5 transition-colors text-left ${isActive ? "bg-white/20 font-medium text-white" : "text-white hover:bg-white/10"}`

function MenuLink(item) {
  const { to, label, icon: Icon } = item
  const isActive = isActiveItem(item, useLocation().pathname)

  return (
    <Link to={to} aria-current={isActive ? "page" : undefined} className={menuLinkClassName({ isActive })}>
      <Icon className="size-5" aria-hidden="true" />
      {label}
    </Link>
  )
}

// Below md: a top bar with the current section and a button opening the navigation as a drawer.
export default function MobileMenu({ session, onSignIn }) {
  const { pathname } = useLocation()
  const [open, setOpen] = useState(false)
  const dialogRef = useRef(null)

  useEffect(() => {
    const dialog = dialogRef.current
    if (open && !dialog.open) dialog.showModal()
    if (!open && dialog.open) dialog.close()
  }, [open])

  // Close the drawer once a link has navigated.
  useEffect(() => setOpen(false), [pathname])
  
  const signIn = () => {
    setOpen(false)
    onSignIn()
  }

  return (
    <>
      <header className="flex shrink-0 items-center gap-2 bg-brand px-2 pt-[env(safe-area-inset-top)] text-white md:hidden dark:bg-brand-dark">
        <button type="button" onClick={() => setOpen(true)} aria-label="Open menu" aria-expanded={open}
          className="rounded p-2.5 text-white hover:bg-white/10">
          <Menu className="size-5" aria-hidden="true" />
        </button>
        <span className="py-3 font-semibold flex flex-row">
          RSSReader
          <ChevronRight />
          {currentItem(pathname)?.label}
        </span>
      </header>

      <dialog
        ref={dialogRef}
        onClose={() => setOpen(false)}
        aria-label="Menu"
        className="m-0 h-dvh max-h-none w-full max-w-none bg-brand p-0 text-white md:hidden dark:bg-brand-dark"
      >
        <nav aria-label="Main" className="flex h-full flex-col p-3 pt-[max(0.75rem,env(safe-area-inset-top))] pb-[max(0.75rem,env(safe-area-inset-bottom))]">
          <div className="mb-2 flex items-center justify-between pl-3">
            <span className="font-semibold">RSSReader</span>
            <button type="button" onClick={() => setOpen(false)} aria-label="Close menu" className="rounded p-2.5 text-white/80 hover:bg-white/10 hover:text-white">
              <X className="size-5" aria-hidden="true" />
            </button>
          </div>

          <ul className="space-y-1">
            {mainItems.map((item) => <li key={item.to}><MenuLink {...item} /></li>)}
          </ul>

          <ul className="mt-auto space-y-1 border-t border-white/20 pt-3">
            {footerItems.map((item) => <li key={item.to}><MenuLink {...item} /></li>)}
            {session.signedIn && (
              <li>
                {/* The job queue dashboard is a server page, outside the React app. */}
                <a href={session.jobsPath} className={menuLinkClassName({ isActive: false })}>
                  <ListChecks className="size-5" aria-hidden="true" />
                  Jobs
                </a>
              </li>
            )}
            <li>
              {session.signedIn
                ? (
                  <SignOutButton path={session.signOutPath} className={menuLinkClassName({ isActive: false })}>
                    <CircleUserRound className="size-5" aria-hidden="true" />
                    Sign out
                  </SignOutButton>
                )
                : (
                  <button type="button" onClick={signIn} className={menuLinkClassName({ isActive: false })}>
                    <LogIn className="size-5" aria-hidden="true" />
                    Sign in
                  </button>
                )}
            </li>
          </ul>
        </nav>
      </dialog>
    </>
  )
}
