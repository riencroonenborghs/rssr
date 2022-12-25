# frozen_string_literal: true

module Subscriptions
  class CreateSubscription
    include Base

    attr_reader :user, :name, :tag_list, :url, :description,
                :feed, :subscription

    def initialize(user:, name:, tag_list:, url:, description:)
      @user = user
      @name = name
      @tag_list = tag_list
      @url = url
      @description = description
    end

    def perform
      ActiveRecord::Base.transaction do
        find_or_create_feed
        return unless success?

        subscription_exists?
        return unless success?

        @subscription = user.subscriptions.build(feed_id: feed.id)

        if subscription.save
          RefreshFeedJob.perform_in(5.seconds, @feed.id)
        else
          errors.merge!(subscription.errors)
        end
      end
    end

    private

    def find_or_create_feed
      return if (@feed = Feed.find_by(url: url))

      build_feed
      errors.merge!(feed.errors) unless feed.save
    end

    def subscription_exists?
      return unless user.subscriptions.exists?(feed_id: @feed.id)

      errors.add(:base, "subscription already exists")
    end

    def build_feed
      @feed = Feed.new(name: name, url: url, tag_list: tag_list, description: description)
      feed.feed_type =  case url
                        when /reddit\.com/
                          Feed::SUBREDDIT
                        else
                          Feed::RSS
                        end

      loader = Feeds::GuessDetails.perform(feed: feed)
      feed.name = loader.name if loader.success?
    end
  end
end
