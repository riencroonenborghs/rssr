class RefreshFeedJob
  include Sidekiq::Job

  def perform(feed_id)
    Feeds::RefreshFeed.perform(feed_id: feed_id)
  end
end
