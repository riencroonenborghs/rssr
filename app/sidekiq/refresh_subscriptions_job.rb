class RefreshSubscriptionsJob < ActiveJob::Base
  def perform(*args)
    Subscription.active.distinct(:feed_id).pluck(&:feed_id).each do |feed_id|
      RefreshFeedJob.perform_later(feed_id)
    end
  end
end
