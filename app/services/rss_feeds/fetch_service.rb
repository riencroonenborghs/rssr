module RssFeeds
  # Fetches an active feed and stores entries not seen before. Inactive feeds are skipped.
  # last_fetched_at is always recorded; error holds the failure message, or nil on success.
  # The feed's title is stored when the feed has none yet, so a title chosen by the user is kept.
  class FetchService < ApplicationService
    def initialize(rss_feed)
      @rss_feed = rss_feed
    end

    def call
      unless rss_feed.active?
        log(:info, "Skipping inactive feed")
        return
      end

      log(:info, "Fetching feed")
      attributes = { last_fetched_at: Time.current, error: nil }
      begin
        parsed = DownloadService.call(rss_feed.url)
        title = parsed.title.presence&.strip
        attributes[:title] = title if title && rss_feed.title.blank?
        created = RssEntries::CreateService.call(rss_feed, parsed.entries)
        log(:info, "Fetched feed, created #{created} entries")
      rescue StandardError => e
        attributes[:error] = "#{e.class}: #{e.message}"
        log(:error, "Failed to fetch feed: #{attributes[:error]}")
      end
      rss_feed.update_columns(attributes)
    end

    private
      attr_reader :rss_feed

      def log(level, message)
        Rails.logger.public_send(level, "[#{self.class.name}] feed=#{rss_feed.id} url=#{rss_feed.url} #{message}")
      end
  end
end
