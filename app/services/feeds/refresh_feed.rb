# frozen_string_literal: true

module Feeds
  class RefreshFeed
    include Base

    validates :feed, presence: true
    validate :feed_active?

    def initialize(feed_id:)
      @feed = Feed.joins(:subscriptions).where(id: feed_id).merge(Subscription.active).first
    end

    def perform
      return if invalid?

      create_entries
    rescue StandardError => e
      feed.update!(error: e.message)
    ensure
      feed.update!(refresh_at: Time.zone.now)
    end

    private

    attr_reader :feed

    def feed_active?
      errors.add(:feed, "not active") unless feed.active?
    end

    def create_entries
      feed.update!(error: nil)
      loader = Entries::CreateEntries.perform(feed: feed)
      return if loader.success?

      feed.update!(error: loader.errors.full_messages.to_sentence)
    end
  end
end
