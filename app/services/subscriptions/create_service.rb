module Subscriptions
  # Subscribes a user to the feed at a URL, adding the feed if it is new, and returns the feed.
  # A given title becomes the feed's title; without one, a new feed is downloaded to read its
  # title. Raises ActiveRecord::RecordInvalid for an invalid URL or a feed that cannot be
  # downloaded. New feeds have their entries fetched in the background.
  class CreateService < ApplicationService
    def initialize(user, url:, title: nil)
      @user = user
      @url = url.to_s
      @title = title
    end

    def call
      rss_feed = RssFeed.find_or_initialize_by(url: url)
      new_feed = rss_feed.new_record?
      rss_feed.title = title if title.present?
      rss_feed.validate!
      rss_feed.title = download_title(rss_feed) if new_feed && rss_feed.title.blank?

      RssFeed.transaction do
        rss_feed.save!
        user.subscribe(rss_feed)
      end
      RssFeeds::FetchJob.perform_later(rss_feed) if new_feed
      rss_feed
    end

    private
      attr_reader :user, :url, :title

      def download_title(rss_feed)
        RssFeeds::DownloadService.call(rss_feed.url).title
      rescue StandardError => e
        rss_feed.errors.add(:url, "could not be downloaded (#{e.message})")
        raise ActiveRecord::RecordInvalid, rss_feed
      end
  end
end
