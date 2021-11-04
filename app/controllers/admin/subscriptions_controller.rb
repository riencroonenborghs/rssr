module Admin
  class SubscriptionsController < AdminController
    before_action :set_page, only: [:index]

    def index
      @subscriptions = current_user.subscriptions.page(@page)
    end

    def new
      @subscription = current_user.subscriptions.new(feed: Feed.new)
    end

    def create
      service = CreateManualSubscription.call(
        user: current_user,
        name: subscription_params[:name],
        tag_list: subscription_params[:tag_list],
        url: subscription_params[:url],
        description: subscription_params[:description]
      )
      @subscription = service.subscription

      respond_to do |format|
        if service.success?
          format.html { redirect_to admin_discover_path, notice: "You're suscribed to '#{@subscription.feed.name}'." }
        else
          @subscription.feed = service.feed
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def subscribe
      @subscription = current_user.subscriptions.new(feed_id: params[:feed_id])
      @subscription.save
    end

    def unsubscribe
      @subscription = current_user.subscriptions.find_by(id: params[:subscription_id])
      @subscription.destroy
    end

    # def update
    #   respond_to do |format|
    #     if @subscription.update(subscription_params)
    #       format.html { redirect_to admin_subscriptions_path, notice: "Subscription was successfully updated." }
    #     else
    #       format.html { render :edit, status: :unprocessable_entity }
    #     end
    #   end
    # end

    # def destroy
    #   @subscription.destroy
    #   respond_to do |format|
    #     format.html { redirect_to admin_subscriptions_url, notice: "Subscription was successfully destroyed." }
    #   end
    # end

    # def visit
    #   @subscription.visit!
    #   respond_to do |format|
    #     format.html { redirect_to admin_subscriptions_url, notice: "Subscription will be visited soon." }
    #   end
    # end

    private

    def set_page
      @page = params[:page]&.to_i || 1
    end

    # def set_query
    #   @query = params[:query]
    # end

    # def set_subscription
    #   @feed = current_user.subscription.find(params[:id])
    # end

    def subscription_params
      params.require(:subscription).permit(:name, :tag_list, :url, :description)
    end
  end
end
