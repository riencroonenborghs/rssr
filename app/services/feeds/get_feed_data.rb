# frozen_string_literal: true

module Feeds
  class GetFeedData
    include Base

    attr_reader :feed_data

    def initialize(feed:)
      @feed = feed
    end

    def perform
      load_url_data
      return unless success?

      parse_feed_data
    end

    private

    attr_reader :feed, :data

    def load_url_data
      service = GetUrlData.perform(url: feed.rss_url)
      errors.merge!(service.errors) and return unless service.success?

      @data = service.data
    end

    def parse_feed_data
      @feed_data = Feedjira.parse(data)
    rescue StandardError => e
      errors.add(:base, e.message)
    end
  end
end
