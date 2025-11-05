# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  def index
    @page = params[:page] || 1

    if current_user
      @subscriptions = current_user.subscriptions.joins(:feed).order("feeds.name asc").page(@page)
      @feed_counts = Entry.where(feed_id: @subscriptions.pluck(:feed_id)).group(:feed_id).count
    else
      @subscriptions = Subscription.none.page(@page)
    end
  end
end
