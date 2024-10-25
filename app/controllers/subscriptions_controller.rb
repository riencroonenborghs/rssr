# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def index
    set_entries
    set_notifications
  end

  private

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        scope = Entry
          .most_recent_first
          .joins(feed: { subscriptions: :user })
          .joins(feed: { subscriptions: { taggings: :tag } })
          .includes(feed: { subscriptions: { taggings: :tag } })
          .includes([:taggings])
          .merge(Subscription.active.not_hidden_from_main_page)

        if user_signed_in?
          feed_ids = Subscription.where(user_id: current_user.id).select(:feed_id)
          scope = scope.where(feed_id: feed_ids)
        end

        scope.distinct
      end
    end.page(page).per(@pagination_size)
  end

  def set_notifications
    @notifications = {}
    return unless user_signed_in?

    @notifications = current_user.notifications.unacked.group_by(&:watch_group_id)
  end
end
