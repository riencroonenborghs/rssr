class RefreshFeedJob
  include Sidekiq::Job

  def perform(feed_id)
    feed = Feed.joins(:subscriptions).where(id: feed_id).merge(Subscription.active).first
    return unless feed

    feed.refresh!
  end
end
