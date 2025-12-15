# frozen_string_literal: true

class RefreshFeedJob < ApplicationJob
  queue_as :rssreader

  def perform(feed)
    Feeds::RefreshFeed.perform(feed: feed)
  end
end
