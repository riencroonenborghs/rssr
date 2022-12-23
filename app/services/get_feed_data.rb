# frozen_string_literal: true

class GetFeedData
  include Base

  attr_reader :feed, :feed_data

  def initialize(feed:)
    @feed = feed
  end

  def perform
    load_url_data
    return unless success?

    @feed_data = Feedjira.parse(data)
  rescue StandardError => e
    errors.add(:base, e.message)
  end

  private

  attr_reader :data

  def load_url_data
    service = GetUrlData.perform(url: feed.url)
    errors.merge!(service.errors) and return unless service.success?

    @data = service.data
  end
end
