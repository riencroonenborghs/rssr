# frozen_string_literal: true

class GuessFeedDetails
  include Base

  attr_reader :name

  def initialize(feed:)
    @feed = feed
  end

  def perform
    get_feed_data
    return unless success?

    @name = @feed_data&.title
  end

  private

  def get_feed_data
    service = GetFeedData.perform(feed: @feed)
    errors.merge!(service.errors) and return unless service.success?

    @feed_data = service.feed_data
  end
end
