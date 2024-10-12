# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def today
    set_entries(timespan: :today)

    @notifications = user_signed_in? ? current_user.notifications.unacked : []
  end

  def yesterday
    set_entries(timespan: :yesterday)
  end

  private

  def set_entries(timespan:)
    @entries = offset_scope do
      filtered_scope do
        scope = Entry
          .most_recent_first
          .send(timespan)
          .joins(feed: { subscriptions: :user })
          .joins(feed: { subscriptions: { taggings: :tag } })
          .includes(feed: { subscriptions: { taggings: :tag } })
          .merge(Subscription.active.not_hidden_from_main_page)

        if user_signed_in?
          feed_ids = Subscription.where(user_id: current_user.id).select(:feed_id)
          scope = scope.where(feed_id: feed_ids)
        end

        scope.distinct
      end
    end.page(page).per(@pagination_size)
  end
end
