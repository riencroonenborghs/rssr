# frozen_string_literal: true

class GetFeedData
  include Base

  attr_reader :feed_data

  def initialize(feed:)
    @feed = feed
  end

  def perform
    get_url_data
    return if failure?

    parse_feed_data
  end

  private

  def get_url_data
    service = GetUrlData.perform(url: @feed.rss_url)
    if service.success?
      @data = service.data
      return
    end

    errors.add(:base, "Could not get URL data: #{service.errors.full_messages.to_sentence}")
  end

  def parse_feed_data
    @feed_data = Feedjira.parse(@data)
  rescue StandardError => e
    errors.add(:base, e.message)
  end
end
