class SyncFeedJob
  include Sidekiq::Job

  def perform(feed_id)
    # only when the corresponding subscription is active
    feed = Feed.joins(:subscriptions).where(id: feed_id).merge(Subscription.active).first
    return unless feed

    feed.sync!
  end
end