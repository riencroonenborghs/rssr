module RssFeeds
  # Fetches a single feed and creates its new entries.
  class FetchJob < ApplicationJob
    queue_as :default

    # The feed was deleted between enqueueing and performing.
    discard_on ActiveJob::DeserializationError

    def perform(rss_feed)
      FetchService.call(rss_feed)
    end
  end
end
