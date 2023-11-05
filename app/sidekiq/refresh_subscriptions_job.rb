# frozen_string_literal: true

class RefreshSubscriptionsJob
  include Sidekiq::Job

  def perform
    Subscription.active.distinct(:feed_id).pluck(:feed_id).each do |feed_id|
      RefreshFeedJob.perform_async({ feed_id: feed_id }.to_json)
    end
  end
end
