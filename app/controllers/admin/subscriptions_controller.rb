module Admin
  class SubscriptionsController < AdminController
    before_action :set_page, only: %i[index search]

    def index
      @subscriptions = current_user.subscriptions.joins(:feed).order(active: :desc, "feeds.name" => :asc).page(@page).per(@pagination_size)
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
          format.html { redirect_to admin_subscriptions_path, notice: "You're suscribed to '#{@subscription.feed.name}'." }
        else
          @subscription.feed = service.feed
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def subscribe
      @subscription = current_user.subscriptions.new(feed_id: params[:feed_id])
      @subscription.save
      @subscription.feed.sync! unless @subscription.feed.last_visited.present?
    end

    def unsubscribe
      @subscription = current_user.subscriptions.find_by(id: params[:subscription_id])
      @subscription.destroy
    end

    def sync
      SyncAllSubscriptionsJob.perform_async

      respond_to do |format|
        format.html { redirect_to admin_subscriptions_path, notice: "All subscriptions queued for syncing." }
      end
    end

    def toggle_active
      subscription = current_user.subscriptions.find(params[:id])
      subscription.toggle_active!
      redirect_to request.referer
    end

    def search
      @query = params[:query]
      unless @query.present?
        redirect_to action: :index
        return
      end

      @subscriptions = current_user.subscriptions.joins(:feed).where("upper(feeds.name) like ?", "%#{@query.upcase}%").order(active: :desc, "feeds.name" => :asc).page(@page).per(@pagination_size)
      render :index
    end

    private

    def set_page
      @page = params[:page]&.to_i || 1
    end

    def subscription_params
      params.require(:subscription).permit(:name, :tag_list, :url, :description)
    end
  end
end
