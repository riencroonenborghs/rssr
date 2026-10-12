module RssFeeds
  # Downloads and parses the feed at a URL, returning the Feedjira feed. Raises on a timeout, a
  # non-success response or a body that is not a feed.
  class DownloadService < ApplicationService
    TIMEOUT = 15.seconds

    def initialize(url)
      @url = url
    end

    def call
      response = HTTParty.get(url, timeout: TIMEOUT.to_i)
      raise "HTTP #{response.code}" unless response.success?

      Feedjira.parse(response.body)
    end

    private
      attr_reader :url
  end
end
