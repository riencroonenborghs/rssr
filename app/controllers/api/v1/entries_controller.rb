# frozen_string_literal: true

module Api
  module V1
    class EntriesController < Api::BaseController
      include FeedEntries

      def show
        set_feed

        unless @feed
          redirect_to root_path
          return
        end

        @entry = @feed.entries.find_by(id: params[:id])

        unless @entry
          redirect_to root_path
          return
        end

        @tags = [].tap do |ret|
          if user_signed_in?
            subscription = current_user.subscriptions.find_by(feed_id: @feed_id)
            ret << subscription.tags
          end

          ret << @entry.tags
        end.flatten.uniq

        current_user.viewed_entries.create(entry_id: @entry.id) if user_signed_in?
        @viewed = true
        @bookmarks = @entry.bookmarked?(current_user)
      end

      private

      def set_feed_id
        @feed_id = params[:feed_id]
      end
    end
  end
end
