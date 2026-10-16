# RSS Reader

A self-hosted RSS reader with a three-column layout (navigation, list, details) that adapts to phones,
full-text search, filters and AI summaries of what your feeds say about a topic.

## Features

### Reading
- **Dashboard** of the newest entries across all your subscriptions, loaded a page at a time.
- **Feeds** listed by title with their unread counts; open a feed to see its entries.
- **Entries** are marked read when opened, and link through to the original post.
- **Bookmarks** keep entries you want to come back to; bookmarked entries are never purged.
- **Signed out**, all feeds and entries can be browsed read-only.

### Subscriptions
- **Add a feed** by URL, with an optional title; without one, the feed's own title is used.
- **Reload** a single feed, or **reload all** of them, to fetch new entries without waiting for the
  scheduled refresh. Each feed shows when it was last fetched and its last fetch error.
- **Unsubscribe** from a feed; your bookmarks of its entries are kept.

### Finding entries
- **Full-text search** of entry titles and summaries: stemmed, case-insensitive, every word must match,
  and the last word matches as a prefix so results follow along while typing.
- **Filters** hide matching entries from the dashboard, feeds and search, either by keywords
  (all words must appear) or by a Ruby regular expression.

### Summaries
- Enter **keywords** and a **period** (24 hours, week or 2 weeks) and Claude writes a briefing of the
  matching posts, grouped by theme.
- Each point cites the posts it is based on as `[n]`, linking to the entry; the summarized posts are
  listed alongside.
- Posts are matched the same way as search, from your subscriptions with your filters applied.
  At most the 100 newest matching posts are summarized.

### Background jobs
- Every feed is refreshed **every 30 minutes**.
- Entries older than **2 weeks** are purged daily, except bookmarked ones.
- Signed in, the Solid Queue dashboard is at `/solid_queue`.

### Settings
- **Theme**: system, light or dark.
- **Entry layout**: regular, with images, or compact.

## Stack

- **Backend**: Ruby 3.3, Rails 8.1, SQLite with an FTS5 full-text index
- **Jobs and caching**: Solid Queue (with recurring jobs), Solid Cache, Solid Cable
- **Auth**: Devise
- **Feeds**: Feedjira for parsing, HTTParty for downloading
- **AI**: Anthropic Ruby SDK, Claude Opus 5.5
- **Frontend**: React 19 and React Router 7, served by Rails as a single page app talking to a JSON API
  (Jbuilder); Tailwind CSS 4, Lucide icons, bundled with esbuild
- **Tests**: RSpec, Capybara with headless Chrome, WebMock
- **Deployment**: Capistrano with Puma

## Setup

Requires Ruby 3.3.9, Node 20 and Yarn.

```sh
bin/setup          # installs dependencies and prepares the database
bin/dev            # runs the web server, JS and CSS watchers, and the job worker
```

Then open http://localhost:3000. There is no sign-up page; create a user in the console:

```sh
bin/rails runner 'User.create!(email: "you@example.com", password: "a-long-password")'
```

### Configuration

| Variable        | Purpose                                         |
| --------------- | ----------------------------------------------- |
| `ANTHROPIC_API` | Anthropic API key, required for summaries only. |

Variables can be set in a `.env` file (loaded by dotenv-rails).

## Tests

```sh
bundle exec rspec
```
