class RefreshSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    scope = Feed.where(id: Subscription.active.distinct(:feed_id).pluck(:feed_id))
  
    scope.find_each do |feed|
      wait_time_in_s = rand(1..90)
      RefreshFeedJob.set(wait_until: wait_time_in_s.seconds.from_now).perform_later(feed)
    end
  end
end
