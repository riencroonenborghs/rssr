module Admin
  class SubscriptionsController < AdminController
    # before_action :set_subscription, only: %i[edit update destroy visit]
    # before_action :set_page, only: %i[new]
    # before_action :set_query, only: %i[new]

    # def index
    #   @subscriptions = current_user.subscriptions
    # end

    # def new
    #   @subscription = current_user.subscriptions.new
    #   @feeds = SearchFeeds.call(user: current_user, query: @query, page: @page).feeds
    # end

    def create
      @subscription = current_user.subscriptions.new(feed_id: params[:feed_id])
 
      respond_to do |format|
        @subscription.save
        format.js {}
        # if @subscription.save
        #   format.html { redirect_to admin_subscriptions_path, notice: "Subscription was successfully created." }
        # else
        #   format.html { render :new, status: :unprocessable_entity }
        # end
      end
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

    # def set_page
    #   @page = params[:page]&.to_i || 1
    # end

    # def set_query
    #   @query = params[:query]
    # end

    # def set_subscription
    #   @feed = current_user.subscription.find(params[:id])
    # end

    # def subscription_params
    #   params.require(:subscription).permit(:feed_id)
    # end
  end
end
