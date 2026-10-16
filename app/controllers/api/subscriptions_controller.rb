module Api
  # Lists the signed in user's subscriptions, subscribes them to a feed by URL, with an optional
  # title, returning the subscription, and unsubscribes them from a feed.
  class SubscriptionsController < BaseController
    before_action :authenticate_user!

    def index
      @subscriptions = current_user.subscriptions.joins(:rss_feed).includes(:rss_feed).merge(RssFeed.by_title)
    end

    def create
      rss_feed = Subscriptions::CreateService.call(current_user, url: params[:url], title: params[:title])
      @subscription = current_user.subscriptions.find_by!(rss_feed: rss_feed)
      render :show, status: :created
    end

    # Removes the subscription; the feed itself stays, as other users may be subscribed to it.
    def destroy
      current_user.subscriptions.find(params[:id]).destroy!
      head :no_content
    end
  end
end
