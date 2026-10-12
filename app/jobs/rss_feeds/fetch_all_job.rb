module RssFeeds
  # Enqueues a FetchJob for every active feed. Scheduled in config/recurring.yml.
  class FetchAllJob < ApplicationJob
    queue_as :default

    def perform
      RssFeed.active.find_in_batches do |rss_feeds|
        ActiveJob.perform_all_later(rss_feeds.map { |rss_feed| FetchJob.new(rss_feed) })
      end
    end
  end
end
