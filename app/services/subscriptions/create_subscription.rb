# frozen_string_literal: true

module Subscriptions
  class CreateSubscription
    include Service

    attr_reader :subscription

    def initialize(user:, url:, title:, get_title_from_url:, tag_names:)
      @user = user
      @url = url
      @title = title
      @get_title_from_url = get_title_from_url
      @tag_names = tag_names
    end

    def perform
      ActiveRecord::Base.transaction do
        find_or_create_feed
        return if failure?

        create_subscription
        return if failure?

        RefreshFeedJob.perform_later(@feed)
      end
    end

    private

    def find_or_create_feed
      @feed = Feed.find_by(url: @url)
      return if @feed

      @feed = Feed.new(url: @url, title: @title)
      @feed.title = Feeds::GetFeedTitle.perform(url: @url).title if @get_title_from_url
      return if @feed.save

      copy_errors(@feed.errors)
    end

    def subscription_exists?
      return false unless @user.subscriptions.exists?(feed_id: @feed.id)

      errors.add(:base, "Subscription already exists")
    end

    def create_subscription
      if @user.subscriptions.exists?(feed_id: @feed.id)
        add_error("Subscription already exists")
        return
      end

      @subscription = @user.subscriptions.build(feed_id: @feed.id)
      if @subscription.save
        @subscription.add_tags(@tag_names)
        return
      end

      copy_errors(@subscription.errors)
    end
  end
end
