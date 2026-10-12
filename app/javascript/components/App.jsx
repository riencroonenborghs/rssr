import { Route, Routes } from "react-router"
import AddFeedPage from "./AddFeedPage"
import { DetailColumn, ListColumn, ListHeader, Message } from "./Columns"
import EntriesPage from "./entries/EntriesPage"
import EntryDetail from "./entries/EntryDetail"
import EntryList from "./feeds/EntryList"
import FeedsPage from "./feeds/FeedsPage"
import FiltersPage from "./FiltersPage"
import Layout from "./Layout"
import Page from "./Page"
import SearchPage from "./SearchPage"
import SettingsPage from "./SettingsPage"

function SignInRequired({ title, children }) {
  return (
    <>
      <ListColumn>
        <ListHeader title={title} />
        <Message>{children}</Message>
      </ListColumn>
      <DetailColumn />
    </>
  )
}

// Paths must also be listed in config/routes.rb so that reloading a page serves the app.
export default function App({ session }) {
  return (
    <Routes>
      <Route element={<Layout session={session} />}>
        <Route element={<EntriesPage session={session} apiPath="/api/entries" basePath="/" title="Dashboard" emptyMessage="There are no entries yet." />}>
          <Route index element={<Message>Select an entry to read it.</Message>} />
          <Route path="entries/:entryId" element={<EntryDetail session={session} backTo="/" backLabel="Dashboard" />} />
        </Route>
        <Route path="feeds" element={<FeedsPage session={session} />}>
          <Route index element={<Message>Select a feed to see its entries.</Message>} />
          <Route path=":feedId" element={<EntryList session={session} />} />
          <Route path=":feedId/entries/:entryId" element={<EntryDetail session={session} />} />
        </Route>
        {session.signedIn
          ? (
            <Route path="bookmarks" element={<EntriesPage session={session} apiPath="/api/bookmarks" basePath="/bookmarks" title="Bookmarks" emptyMessage="You have no bookmarks yet." />}>
              <Route index element={<Message>Select a bookmark to read it.</Message>} />
              <Route path="entries/:entryId" element={<EntryDetail session={session} backTo="/bookmarks" backLabel="Bookmarks" />} />
            </Route>
          )
          : <Route path="bookmarks/*" element={<SignInRequired title="Bookmarks">Sign in to see your bookmarks.</SignInRequired>} />}
        <Route path="search" element={<SearchPage session={session} />}>
          <Route index element={<Message>Select an entry to read it.</Message>} />
          <Route path="entries/:entryId" element={<EntryDetail session={session} backTo="/search" backLabel="Search" />} />
        </Route>
        <Route path="subscriptions/new" element={session.signedIn
          ? <AddFeedPage />
          : <SignInRequired title="Add a feed">Sign in to add feeds.</SignInRequired>} />
        <Route path="filters" element={session.signedIn
          ? <FiltersPage />
          : <SignInRequired title="Filters">Sign in to manage your filters.</SignInRequired>} />
        <Route path="settings" element={<SettingsPage />} />
        <Route path="*" element={<Page title="Not found" />} />
      </Route>
    </Routes>
  )
}
