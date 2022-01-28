class SyncFeedJob < ApplicationJob
  queue_as :default

  def perform(feed_id)
    feed = Feed.find(feed_id)
    return unless feed

    feed.sync!
  end
end