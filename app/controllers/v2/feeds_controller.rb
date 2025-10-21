# frozen_string_literal: true

module V2
  class FeedsController < V2::BaseController
    def index
      @feeds = current_user ? current_user.feeds : Feed
      @feeds = @feeds.active.by_name.no_error.includes(:entries)
    end

    def show
      @feed = Feed.find_by(id: params[:id])
      @page = params[:page] || 1

      @entries = filtered_scope do
        @feed.entries.most_recent_first
      end
      @entries = @entries.page(@page)

      set_subscriptions_by_feed_id(feed: @feed)
      set_viewed_ids(entries_scope: @entries)
      set_bookmarked_ids(entries_scope: @entries)
    end
  end
end
