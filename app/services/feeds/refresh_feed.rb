# frozen_string_literal: true

module Feeds
  class RefreshFeed
    include Service

    validate :feed_active

    def initialize(feed:)
      @feed = feed
    end

    def perform
      if invalid?
        @feed.update!(error: errors.full_messages.to_sentence)
        return
      end

      create_entries
    ensure
      @feed.update_column(:refresh_at, Time.zone.now)
    end

    private

    attr_reader :feed

    def feed_active
      return if @feed.active?

      add_error("Feed not active")
    end

    def create_entries
      @feed.update!(error: nil)

      service = Entries::CreateEntries.perform(feed: @feed)
      return if service.success?

      @feed.update_column(:error, service.errors.full_messages.to_sentence)
      copy_errors(service.errors)
    end
  end
end
