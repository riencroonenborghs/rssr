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

      build_entries
      return unless success?

      filter_duplicates

      create_entries
      return unless success?
    ensure
      @feed.update(refresh_at: Time.zone.now)
    end

    private

    def load_feed_data
      loader = Feeds::GetFeedData.perform(feed: @feed)
      errors.merge!(loader.errors) and return unless loader.success?
      errors.add(:base, "No feed data") and return unless loader.feed_data.present?

      @feed_data = loader.feed_data
    end

    def build_entries
      builder = BuildEntries.perform(feed: @feed, feed_data: @feed_data)
      errors.merge!(builder.errors) and return unless builder.success?

      @entries = builder.entries
    end

    def filter_duplicates
      new_titles = @entries.map { |entry| entry[:title] }
      existing_titles = Entry.where(title: new_titles).pluck(:title)

      @entries = @entries.reject do |entry|
        existing_titles.include?(entry[:title])
      end
    end

    def create_entries
      Entry.transaction do
        @feed.entries.create!(
          @entries
        )
      end
    end
  end
end
