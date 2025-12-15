# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ScopeHelpers

  def mobile?
    browser.device.mobile?
  end
  helper_method :mobile?

  def unread_count
    @unread_count = filtered_scope do
      user_scope do
        Entry.unread(current_user)
      end
    end.count
  end
  helper_method :unread_count

  def bookmarks_count
    return 0 unless user_signed_in?

    current_user.bookmarks.count
  end
  helper_method :bookmarks_count

  def active_feeds
    feeds = Feed.joins(:subscriptions).where(subscriptions: { active: true }).order(feeds: { title: :asc })
    feeds = feeds.where(subscriptions: { user_id: current_user.id }) if user_signed_in?

    entry_count_by_feed_id = Entry
      .joins(feed: :subscriptions)
      .merge(Subscription.active.not_hidden_from_main_page)
      .group(:feed_id)
      .count

    {}.tap do |ret|
      feeds.each do |feed|
        ret[feed] = entry_count_by_feed_id[feed.id] || 0
      end
    end
  end
  helper_method :active_feeds

  private

  def page
    params[:page] || 1
  end
  helper_method :page
end
