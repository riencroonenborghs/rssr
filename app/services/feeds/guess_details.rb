# frozen_string_literal: true

module Feeds
  class GuessDetails
    include Base

    attr_reader :name, :image_url

    def initialize(feed:)
      @feed = feed
    end

    def perform
      get_feed_data
      return unless success?

      guess_name
    end

    private

    attr_reader :feed, :feed_data

    def get_feed_data
      loader = Feeds::GetFeedData.perform(feed: feed)
      errors.merge!(loader.errors) and return unless loader.success?

      @feed_data = loader.feed_data
    end

    def guess_name
      @name = case feed.feed_type
              when Feed::RSS
                feed_data&.title
              when Feed::SUBREDDIT
                feed_data.dig(:data, :children, 0, :data, :subreddit_name_prefixed)
              end
    end
  end
end
