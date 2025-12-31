# frozen_string_literal: true

module Feeds
  class GetFeedTitle
    include Service

    attr_reader :title

    def initialize(url:)
      @url = url
    end

    def perform
      get_feed_data
      return unless success?

      @title = @feed_data.title
    end

    private

    attr_reader :feed, :feed_data

    def get_feed_data # rubocop:disable Naming/AccessorMethodName
      service = Feeds::GetFeedData.perform(url: @url)
      if service.success?
        @feed_data = service.feed_data
        return
      end

      copy_errors(service.errors)
    end
  end
end
