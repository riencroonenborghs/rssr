# frozen_string_literal: true

class UpdateSubscriptionService
  include Base

  attr_reader :subscription

  def initialize(user:, id:, params:)
    @user = user
    @id = id

    @hide_from_main_page = params.delete(:hide_from_main_page)
    @params = params
  end

  def perform
    find_subscription
    return unless success?

    update_subscriptions
    return unless success?

    RefreshFeedJob.perform_in(5.seconds, subscription.feed.id) if url_changed
  end

  private

  attr_reader :user, :id, :params, :url_changed, :hide_from_main_page

  def find_subscription
    @subscription = user.subscriptions.find_by(id: id)
    errors.add(:base, "No subscription found") unless subscription
  end

  def update_subscriptions
    subscription.hide_from_main_page = hide_from_main_page
    subscription.feed.assign_attributes(params)
    @url_changed = subscription.feed.url_changed?
    errors.merge!(subscription.errors) unless subscription.save
    errors.merge!(subscription.feed.errors) unless subscription.feed.save
  end
end
