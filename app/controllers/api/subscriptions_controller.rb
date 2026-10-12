module Api
  # Subscribes the signed in user to a feed by URL, with an optional title.
  class SubscriptionsController < BaseController
    before_action :authenticate_user!

    def create
      @rss_feed = Subscriptions::CreateService.call(current_user, url: params[:url], title: params[:title])
      render :create, status: :created
    end
  end
end
