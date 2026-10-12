module Api
  class EntriesController < BaseController
    # The entries of all visible feeds or, with feed_id, of that visible feed; newest first, a page
    # at a time ({ entries:, next_page: }).
    def index
      entries = visible_entries
      entries = entries.where(rss_feed: visible_feeds.find(params[:feed_id])) if params[:feed_id]
      render_entries_page(entries)
    end

    def show
      @entry = viewable_entries.includes(:rss_feed).find(params[:id])
      load_entry_states([ @entry ])
    end
  end
end
