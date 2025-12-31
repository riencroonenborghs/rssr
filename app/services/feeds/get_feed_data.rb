# frozen_string_literal: true

module Feeds
  class GetFeedData
    include Service

    attr_reader :feed_data

    def initialize(url:)
      @url = url
    end

    def perform
      get_url_data
      return unless success?

      parse_url_data
    end

    private

    def get_url_data # rubocop:disable Naming/AccessorMethodName
      service = GetUrlData.perform(url: @url)
      if service.success?
        @url_data = service.data
        return if @url_data

        add_error("No URL data")
        return
      end

      copy_errors(service.errors)
    end

    def parse_url_data
      @feed_data = Feedjira.parse(@url_data)
      return if @feed_data

      add_error("No feed data")
    rescue StandardError => e
      add_error(e.message)
    end
  end
end
