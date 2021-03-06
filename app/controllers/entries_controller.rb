class EntriesController < ApplicationController
  before_action :set_current_user_feed, if: -> { user_signed_in? }
  before_action :set_global_feed, if: -> { !user_signed_in? }

  def index
    set_entries
    set_bookmarks
    set_viewed
    paged_render
  end

  def today
    set_today_entries
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_feed
    user_signed_in? ? set_current_user_feed : set_global_feed
  end

  def set_global_feed
    @feed = Feed.find(params[:feed_id])
  end

  def set_current_user_feed
    @feed = current_user.feeds.find(params[:feed_id])
  end

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        @feed
          .entries
          .joins(feed: :subscriptions)
          .merge(Subscription.active)
          .most_recent_first
      end
    end.page(page).per(@pagination_size)
  end

  def set_today_entries
    @entries = offset_scope do
      filtered_scope do
        @feed
          .entries
          .joins(feed: :subscriptions)
          .merge(Subscription.active)
          .most_recent_first
          .today
      end
    end.page(page).per(@pagination_size)
  end
end
