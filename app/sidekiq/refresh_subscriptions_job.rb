# frozen_string_literal: true

class RefreshSubscriptionsJob
  include Sidekiq::Job

  def perform
    Subscription.active.distinct(:feed_id).pluck(:feed_id).each do |feed_id|
      wait_time_in_s = rand(1..90)
      RefreshFeedJob.perform_in(wait_time_in_s.seconds, { feed_id: feed_id }.to_json)
    end
  end
end
