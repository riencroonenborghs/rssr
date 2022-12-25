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

      load_feed_data
    end

    private

    attr_reader :feed, :data

    def load_url_data
      service = GetUrlData.perform(url: feed.url)
      errors.merge!(service.errors) and return unless service.success?

      @data = service.data
    end

    def load_feed_data
      case feed.feed_type
      when Feed::RSS
        load_rss_data
      when Feed::SUBREDDIT
        load_subreddit_data
      end
    end

    def load_rss_data
      @feed_data = Feedjira.parse(data)
    rescue StandardError => e
      errors.add(:base, e.message)
    end

    def load_subreddit_data
      @feed_data = JSON.parse(data).deep_symbolize_keys
    rescue StandardError => e
      errors.add(:base, e.message)
    end
  end
end
