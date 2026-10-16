module Api
  # Fetches a subscribed feed's new entries now, rather than waiting for the scheduled fetch, and
  # returns the subscription with the feed's updated state.
  class SubscriptionReloadsController < BaseController
    before_action :authenticate_user!

    def create
      @subscription = current_user.subscriptions.includes(:rss_feed).find(params[:subscription_id])
      RssFeeds::FetchService.call(@subscription.rss_feed)
      render "api/subscriptions/show"
    end
  end
end
