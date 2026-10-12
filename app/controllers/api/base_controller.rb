module Api
  # JSON endpoints for the React app. Feeds and entries can be viewed signed out; a signed in
  # user sees only their subscriptions, after their filters, with their read and bookmark state.
  class BaseController < ApplicationController
    PER_PAGE = 50

    helper_method :entry_read?, :entry_bookmarked?

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Not found" }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render json: { error: error.record.errors.full_messages.to_sentence }, status: :unprocessable_content
    end

    private
      def visible_feeds
        user_signed_in? ? current_user.rss_feeds : RssFeed
      end

      # Entries for listing, newest first.
      def visible_entries
        user_signed_in? ? RssEntries::FilteredService.call(current_user) : RssEntry.newest_first
      end

      # Entries that can be opened: signed in, those of subscribed feeds (including ones filters
      # hide from lists) and bookmarked ones.
      def viewable_entries
        return RssEntry unless user_signed_in?

        RssEntry.where(rss_feed: visible_feeds).or(RssEntry.where(id: current_user.bookmarks.select(:rss_entry_id)))
      end

      # Renders a page of the ordered entries as { entries:, next_page: }.
      def render_entries_page(entries)
        page = [ params[:page].to_i, 1 ].max
        entries = entries.includes(:rss_feed).offset((page - 1) * PER_PAGE).limit(PER_PAGE + 1).to_a
        @next_page = page + 1 if entries.size > PER_PAGE
        @entries = entries.first(PER_PAGE)
        load_entry_states(@entries)
        render "api/entries/page"
      end

      # Loads which of the entries the signed in user has read and bookmarked, for the views.
      def load_entry_states(entries)
        @read_entry_ids = @bookmarked_entry_ids = Set.new
        return unless user_signed_in?

        @read_entry_ids = current_user.rss_entry_reads.where(rss_entry: entries).pluck(:rss_entry_id).to_set
        @bookmarked_entry_ids = current_user.bookmarks.where(rss_entry: entries).pluck(:rss_entry_id).to_set
      end

      def entry_read?(entry)
        @read_entry_ids.include?(entry.id)
      end

      def entry_bookmarked?(entry)
        @bookmarked_entry_ids.include?(entry.id)
      end
  end
end
