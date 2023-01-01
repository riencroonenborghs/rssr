# frozen_string_literal: true

module Subscriptions
  class CreateSubscription
    include Base

    attr_reader :feed, :subscription
    attr_reader :default_feed, :default_subscription

    def initialize(user:, name:, tag_list:, url:, description:, hide_from_main_page:)
      @user = user
      @name = name
      @tag_list = tag_list
      @url = url
      @description = description
      @hide_from_main_page = hide_from_main_page

      @default_feed = Feed.new(
        name: name,
        url: url,
        tag_list: tag_list,
        description: description
      )
      @default_subscription = user.subscriptions.build(feed: default_feed, hide_from_main_page: hide_from_main_page)
    end

    def perform
      ActiveRecord::Base.transaction do
        find_or_create_feed
        return unless success?

        subscription_exists?
        return unless success?

        @subscription = user.subscriptions.build(feed_id: feed.id, hide_from_main_page: hide_from_main_page)

        if subscription.save
          RefreshFeedJob.perform_in(5.seconds, @feed.id)
        else
          errors.merge!(subscription.errors)
        end
      end
    end

    private

    attr_reader :user, :name, :tag_list, :url, :description, :hide_from_main_page
    attr_reader :rss_feeds, :guesser

    def find_or_create_feed
      return if (@feed = Feed.find_by(url: url))
      
      create_feed
    end

    def create_feed
      @feed = Feed.new(name: name, url: url, tag_list: tag_list, description: description)

      find_rss_feeds
      return unless success?

      feed.rss_url = rss_feeds.first.href
      feed.name = rss_feeds.first.title if feed.name.blank?

      guess_details
      feed.name = guesser.name if guesser.success? && feed.name.blank?

      errors.merge!(feed.errors) unless feed.save
    end

    def find_rss_feeds
      finder = FindRssFeeds.perform(url: url)
      errors.merge!(finder.errors) unless finder.success?
      errors.add(:base, "no RSS feeds found") and return unless finder.rss_feeds.any?

      @rss_feeds = finder.rss_feeds
    end

    def subscription_exists?
      return unless user.subscriptions.exists?(feed_id: @feed.id)

      errors.add(:base, "subscription already exists")
    end

    def guess_details
      @guesser = Feeds::GuessDetails.perform(feed: feed)
    end
  end
end
