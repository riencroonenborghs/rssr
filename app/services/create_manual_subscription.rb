class CreateManualSubscription < AppService
  attr_reader :user, :name, :tag_list, :url, :description, :feed, :subscription

  def initialize(user:, name:, tag_list:, url:, description:) # rubocop:disable Lint/MissingSuper
    @user = user
    @name = name
    @tag_list = tag_list
    @url = url
    @description = description
  end

  def call
    find_or_create_feed
    subscribe_to_feed
  end

  private

  def find_or_create_feed
    return if (@feed = Feed.find_by(url: url))

    create_feed
  end

  def create_feed
    @feed = Feed.create(name: name, url: url, tag_list: tag_list, description: description)
    errors.merge!(feed.errors) unless feed.persisted?
  end

  def subscribe_to_feed
    @subscription = user.subscriptions.create(feed_id: feed.id)
    errors.merge!(subscription.errors) unless subscription.persisted?
  end
end
