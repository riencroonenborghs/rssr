# frozen_string_literal: true

class RefreshSubscriptionsJob < ApplicationJob
  queue_as :rssreader

  def perform
    Feed.joins(:subscriptions).where(subscriptions: { active: true }).distinct.each do |feed|
      RefreshFeedJob.perform_later(feed)
    end
  end
end
