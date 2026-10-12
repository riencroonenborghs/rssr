module Api
  class FeedsController < BaseController
    # The visible feeds with their number of unread entries. Signed out, nothing has been read.
    def index
      entries = visible_entries.unscope(:order)
      entries = entries.unread_by(current_user) if user_signed_in?
      @unread_counts = entries.group(:rss_feed_id).count
      @feeds = visible_feeds.by_title
    end
  end
end
