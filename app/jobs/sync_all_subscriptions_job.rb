class SyncAllSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    User.all.each do |user|
      user.subscriptions.active.each do |subscription|
        SyncFeedJob.perform_later(subscription.feed_id)
      end
    end
  end
end