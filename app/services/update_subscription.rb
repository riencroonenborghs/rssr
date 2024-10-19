# frozen_string_literal: true

class UpdateSubscription
  include Base

  attr_reader :subscription

  def initialize(user:, id:, params:)
    @user = user
    @id = id
    @params = params
  end

  def perform
    find_subscription
    return unless success?

    update_subscriptions
  end

  private

  def find_subscription
    @subscription = @user.subscriptions.find_by(id: @id)
    errors.add(:base, "No subscription found") unless subscription
  end

  def update_subscriptions
    subscription.hide_from_main_page = @params.delete(:hide_from_main_page)
    subscription.tag_list = @params.delete(:tag_list)
    subscription.feed.assign_attributes(@params)    

    errors.merge!(subscription.errors) unless subscription.save
    errors.merge!(subscription.feed.errors) unless subscription.feed.save
  end
end
