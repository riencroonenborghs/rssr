# frozen_string_literal: true

class CreateEntries
  include Base

  def initialize(feed:)
    @feed = feed
  end

  def perform
    load_feed_data
    return if failure?

    build_entries_hash
    return if failure?

    create_entries
    return if failure?

    @feed.update(refresh_at: Time.zone.now)
  end

  private

  def load_feed_data
    service = GetFeedData.perform(feed: @feed)
    if service.success?
      if service.feed_data.present?
        @feed_data = service.feed_data
        return
      end

      errors.add(:base, "No feed data")
    else
      errors.add(:base, "Could not get feed data: #{service.errors.full_messages.to_sentence}")
    end
  end

  def build_entries_hash
    @entries_builder = BuildEntries.perform(feed: @feed, feed_data: @feed_data)
    return if @entries_builder.success?

    errors.add(:base, "Could not build entries: #{@entries_builder.errors.full_messages.to_sentence}")
  end

  def create_entries
    Entry.transaction do
      @entries_builder.entries.each do |entry|
        entry = @feed.entries.create!(entry)
        matcher = FindMatch.perform(entry: entry)
        if matcher.tv
          TvEntry.create!(matcher.data.update(entry: entry))
        elsif matcher.movie
          MovieEntry.create!(matcher.data.update(entry: entry))
        end
      end
    end
  end
end
