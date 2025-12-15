# frozen_string_literal: true

module FeedEntries
  extend ActiveSupport::Concern

  included do
    before_action :set_feed_id
  end

  private

  def set_feed_id
    raise StandardException, "#set_feed_id implement me"
  end

  def set_feed
    @feed = Feed.find_by(id: @feed_id)
  end

  def set_feed_entries
    @entries = filtered_scope do
      user_scope do
        Entry
          .most_recent_first
          .joins(feed: :subscriptions)
          .merge(Subscription.active.not_hidden_from_main_page)
          .where(feed_id: @feed.id)
          .distinct
      end
    end.page(page)
  end
end