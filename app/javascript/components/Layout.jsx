import { useEffect, useState } from "react"
import { Outlet } from "react-router"
import { useSettings } from "../lib/settings"
import ColumnResizer from "./ColumnResizer"
import MobileMenu from "./MobileMenu"
import Sidebar from "./Sidebar"
import SignInModal from "./SignInModal"

// From md up: three columns (navigation, then the page's list and details columns, see Columns.jsx);
// the list column can be resized. Below md: a top bar with a menu, then one content column at a time.
export default function Layout({ session }) {
  const [signInOpen, setSignInOpen] = useState(false)
  const openSignIn = () => setSignInOpen(true)

  // Follows the saved width, and the dragged width while resizing (saved when the drag ends).
  const { settings, updateSettings } = useSettings()
  const [listWidth, setListWidth] = useState(settings.listWidth)
  useEffect(() => setListWidth(settings.listWidth), [settings.listWidth])
  const saveListWidth = (width) => {
    setListWidth(width)
    updateSettings({ listWidth: width })
  }

  return (
    <div
      style={{ "--list-width": `${listWidth}px` }}
      className="relative flex h-full flex-col text-gray-900 md:grid md:grid-cols-[4rem_var(--list-width)_1fr]"
    >
      <MobileMenu session={session} onSignIn={openSignIn} />
      <Sidebar session={session} onSignIn={openSignIn} />
      <Outlet />
      <ColumnResizer width={listWidth} onResize={setListWidth} onResizeEnd={saveListWidth} />

      {!session.signedIn && (
        <SignInModal open={signInOpen} onClose={() => setSignInOpen(false)} path={session.signInPath} />
      )}
    </div>
  )
}
