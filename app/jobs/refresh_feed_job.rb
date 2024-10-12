class RefreshFeedJob < ApplicationJob
  queue_as :default

  def perform(feed)
    RefreshFeed.perform(feed: feed)
  end
end
