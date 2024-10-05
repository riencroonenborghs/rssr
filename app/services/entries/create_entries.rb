# frozen_string_literal: true

module Entries
  class CreateEntries
    include Base

    def initialize(feed:)
      @feed = feed
    end

    def perform
      load_feed_data
      return unless success?

      set_entries_creator
      return unless success?

      create_new_rss_items
      return unless success?

      feed.update(refresh_at: Time.zone.now)
    end

    private

    attr_reader :feed, :feed_data, :entries_creator

    def load_feed_data
      loader = Feeds::GetFeedData.perform(feed: feed)
      errors.merge!(loader.errors) and return unless loader.success?
      errors.add(:base, "No feed data") and return unless loader.feed_data.present?

      @feed_data = loader.feed_data
    end

    def set_entries_creator
      @entries_creator = CreateRssEntries.perform(feed: feed, feed_data: feed_data)
      errors.merge!(entries_creator.errors) unless entries_creator.success?
    end

    def create_new_rss_items
      Entry.transaction do
        feed.entries.create!(
          entries_creator.rss_items
        )
      end
    end
  end
end
