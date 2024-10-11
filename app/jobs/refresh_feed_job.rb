class RefreshFeedJob < ApplicationJob
  queue_as :bootlegger

  def perform(feed)
    RefreshFeed.perform(feed: feed)
  end
end
