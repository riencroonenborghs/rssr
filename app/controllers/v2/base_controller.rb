# frozen_string_literal: true

module V2
  class BaseController < ActionController::Base
    layout "react"

    def mobile?
      browser.device.mobile?
    end
    helper_method :mobile?

    private

    def set_subscriptions_by_feed_id(feed: nil, entries_scope: nil, feed_ids: nil)
      @subscriptions_by_feed_id = {}
      return unless current_user

      if feed
        @subscriptions_by_feed_id[feed.id] = current_user
          .subscriptions
          .find_by(feed_id: feed.id)
      elsif entries_scope
        @subscriptions_by_feed_id = current_user
          .subscriptions
          .where(feed_id: 
            entries_scope.select(:feed_id)
          ).index_by(&:feed_id)
      elsif feed_ids
        @subscriptions_by_feed_id = current_user
          .subscriptions
          .where(feed_id: feed_ids)
          .index_by(&:feed_id)
      end
    end

    def set_viewed_ids(entries_scope: nil, entry_ids: nil)
      @viewed_ids = []
      return unless current_user

      ids = if entries_scope
        entries_scope.select(:id)
      elsif entry_ids
        entry_ids
      end

      @viewed_ids = ViewedEntry.where(user_id: current_user.id, entry_id: ids).pluck(:entry_id)
    end

    def set_bookmarked_ids(entries_scope: nil, entry_ids: nil)
      @bookmarked_ids = []
      return unless current_user

      ids = if entries_scope
        entries_scope.select(:id)
      elsif entry_ids
        entry_ids
      end

      @bookmarked_ids = Bookmark.where(user_id: current_user.id, entry_id: ids).pluck(:entry_id)
    end

    def filtered_scope
      scope = yield
      return scope unless current_user

      scope = Entries::FilterEntries.perform(user: current_user, scope: scope).scope # rubocop:disable Style/RedundantAssignment

      scope
    end
  end
end
