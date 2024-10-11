# frozen_string_literal: true

class OldRefreshFeedJob
  include Sidekiq::Job

  def perform(args)
    parsed = JSON.parse(args)
    Feeds::RefreshFeed.perform(feed_id: parsed["feed_id"])
  end
end
