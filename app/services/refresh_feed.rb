# frozen_string_literal: true

class RefreshFeed
  include Base

  validate :feed_active

  def initialize(feed:)
    @feed = feed
  end

  def perform
    return if invalid?

    create_entries
  rescue StandardError => e
    @feed.update!(error: e.message)
  ensure
    @feed.update!(refresh_at: Time.zone.now)
  end

  private

  def feed_active
    return if @feed.active?
    
    errors.add(:base, "Feed not active")
  end

  def create_entries
    @feed.update!(error: nil)

    service = CreateEntries.perform(feed: @feed)
    return if service.success?

    @feed.update!(error: service.errors.full_messages.to_sentence)
    errors.add(:base, "Could not create entries: #{service.errors.full_messages.to_sentence}")
  end
end
