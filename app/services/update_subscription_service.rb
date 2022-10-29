class UpdateSubscriptionService
  include AppService

  attr_reader :subscription

  def initialize(user:, id:, params:)
    @user = user
    @id = id
    @params = params
  end

  def call
    find_subscription
    return unless success?

    update_feed
    return unless success?

    RefreshFeedJob.perform_in(5.seconds, subscription.feed.id) if url_changed
  end

  private

  attr_reader :user, :id, :params, :url_changed

  def find_subscription
    @subscription = user.subscriptions.find_by(id: id)
    errors.add(:base, "No subscription found") unless subscription
  end

  def update_feed
    subscription.feed.assign_attributes(params)
    @url_changed = subscription.feed.url_changed?
    errors.merge!(subscription.feed.errors) unless subscription.feed.save
  end
end
