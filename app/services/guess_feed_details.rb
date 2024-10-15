# frozen_string_literal: true

class GuessFeedDetails
  include Base

  attr_reader :name

  def initialize(feed:)
    @feed = feed
  end

  def perform
    set_feed_data
    return unless success?

    guess_name
  end

  private

  attr_reader :feed, :feed_data

  def set_feed_data
    loader = GetFeedData.perform(feed: feed)
    errors.merge!(loader.errors) and return unless loader.success?

    @feed_data = loader.feed_data
  end

  def guess_name
    @name = feed_data&.title
  end
end
