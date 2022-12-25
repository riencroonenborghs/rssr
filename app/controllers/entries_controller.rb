class EntriesController < ApplicationController
  before_action :set_feed

  def index
    set_entries
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_feed
    @feed = if user_signed_in?
              current_user.feeds.find(params[:feed_id])
            else
              Feed.find(params[:feed_id])
            end
  end

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        @feed
          .entries
          .joins(feed: :subscriptions)
          .includes(feed: { taggings: :tag })
          .merge(Subscription.active)
          .most_recent_first
          .distinct
      end
    end.page(page).per(@pagination_size)
  end
end
