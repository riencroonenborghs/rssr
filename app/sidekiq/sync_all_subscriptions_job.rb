class SyncAllSubscriptionsJob
  include Sidekiq::Job

  def perform
    User.all.each do |user|
      user.subscriptions.active.each do |subscription|
        SyncFeedJob.perform_async(subscription.feed_id)
      end
    end
  end
end
