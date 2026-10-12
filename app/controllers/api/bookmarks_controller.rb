module Api
  class BookmarksController < BaseController
    before_action :authenticate_user!

    # The user's bookmarked entries from any feed, most recently bookmarked first, a page at a
    # time. Filters don't apply: the user chose to keep these.
    def index
      render_entries_page(current_user.bookmarked_rss_entries.order("bookmarks.created_at DESC, bookmarks.id DESC"))
    end
  end
end
