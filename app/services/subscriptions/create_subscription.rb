# frozen_string_literal: true

module Subscriptions
  class CreateSubscription
    include Base

    attr_reader :feed, :subscription, :default_feed, :default_subscription

    def initialize(user:, url:, rss_url:, name:, tag_list:, description:, hide_from_main_page:) # rubocop:disable Metrics/ParameterLists
      @url = url
      @rss_url = rss_url
      @user = user
      @name = name
      @tag_list = tag_list
      @description = description
      @hide_from_main_page = hide_from_main_page

      build_defaults
    end

    def perform
      ActiveRecord::Base.transaction do
        find_or_create_feed
        return unless success?

        subscription_exists?
        return unless success?

        build_subscription
        persist_subscription
        return unless success?

        RefreshFeedJob.perform_in(5.seconds, feed.id)
      end
    end

    private

    attr_reader :url, :rss_url, :user, :name, :tag_list, :description, :hide_from_main_page, :rss_feeds, :guesser

    def build_defaults
      @default_feed = Feed.new(
        url: url,
        rss_url: rss_url,
        name: name,
        description: description
      )

      @default_subscription = user.subscriptions.build(
        feed: default_feed,
        hide_from_main_page: hide_from_main_page,
        tag_list: tag_list
      )
    end

    def find_or_create_feed
      return if (@feed = Feed.find_by(url: url))

      create_feed
    end

    def create_feed
      @feed = Feed.new(name: name, url: url, description: description)
      errors.merge!(feed.errors) unless feed.save
    end

    def subscription_exists?
      return unless user.subscriptions.exists?(feed_id: @feed.id)

      errors.add(:base, "subscription already exists")
    end

    def build_subscription
      @subscription = user.subscriptions.build(
        feed_id: feed.id,
        hide_from_main_page: hide_from_main_page,
        tag_list: tag_list
      )
    end

    def persist_subscription
      errors.merge!(subscription.errors) unless subscription.save
    end
  end
end
