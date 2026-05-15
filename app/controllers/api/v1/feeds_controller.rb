# frozen_string_literal: true

module Api
  module V1
    class FeedsController < Api::BaseController
      include FeedEntries

      skip_before_action :authenticate_user!

      def index
        @feeds = Feed.joins(:subscriptions).where(subscriptions: { active: true }).order(feeds: { title: :asc })
        @feeds = @feeds.where(subscriptions: { user_id: current_user.id }) if current_user
        @entry_count_by_feed_id = Entry
          .joins(feed: :subscriptions)
          .group(:feed_id)
          .count
      end

      def show
        set_feed

        unless @feed
          redirect_to root_path
          return
        end

        set_feed_entries
        set_tags_by_entry
        set_viewed_entries
        set_bookmarks
      end

      private

      def set_feed_id
        @feed_id = params[:id]
      end
    end
  end
end
