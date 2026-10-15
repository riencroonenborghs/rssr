import { ListChecks, LogIn, Rss } from "lucide-react"
import { Link, useLocation } from "react-router"
import { isActiveItem, footerItems, signedInFooterItems, mainItems } from "./navigation"
import SignOutButton from "./SignOutButton"

const iconLinkClassName = ({ isActive }) =>
  `flex size-10 items-center justify-center rounded-xl transition-colors ${isActive ? "bg-white/20 text-white shadow-sm ring-1 ring-white/15" : "text-white/80 hover:bg-white/10 hover:text-white"}`

// Icon-only links; the label is the accessible name and shows as a tooltip.
function IconLink(item) {
  const { to, label, icon: Icon } = item
  const isActive = isActiveItem(item, useLocation().pathname)

  return (
    <Link to={to} aria-label={label} title={label} aria-current={isActive ? "page" : undefined}
      className={iconLinkClassName({ isActive })}>
      <Icon className="size-5" aria-hidden="true" />
    </Link>
  )
}

// The desktop navigation column; MobileMenu replaces it below md.
export default function Sidebar({ session, onSignIn }) {
  return (
    <nav aria-label="Main" className="hidden flex-col items-center bg-brand py-3 text-white md:flex dark:bg-brand-dark">
      <div aria-hidden="true" className="mb-4 flex size-9 items-center justify-center rounded-xl bg-white text-brand shadow-sm dark:bg-white/90 dark:text-brand-dark">
        <Rss className="size-5" strokeWidth={2.5} />
      </div>
      <ul className="space-y-1.5">
        {mainItems.map((item) => <li key={item.to}><IconLink {...item} /></li>)}
      </ul>

      <ul className="mt-auto space-y-1.5">
        {session.signedIn && signedInFooterItems.map((item) => <li key={item.to}><IconLink {...item} /></li>)}
        {footerItems.map((item) => <li key={item.to}><IconLink {...item} /></li>)}
        {session.signedIn && (
          <li>
            {/* The job queue dashboard is a server page, outside the React app. */}
            <a href={session.jobsPath} aria-label="Jobs" title="Jobs" className={iconLinkClassName({ isActive: false })}>
              <ListChecks className="size-5" aria-hidden="true" />
            </a>
          </li>
        )}
        <li>
          {session.signedIn
            ? <SignOutButton path={session.signOutPath} className={iconLinkClassName({ isActive: false })} />
            : (
              <button type="button" onClick={onSignIn} aria-label="Sign in" title="Sign in" className={iconLinkClassName({ isActive: false })}>
                <LogIn className="size-5" aria-hidden="true" />
              </button>
            )}
        </li>
      </ul>
    </nav>
  )
}
