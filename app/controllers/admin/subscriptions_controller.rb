module Admin
  class SubscriptionsController < AdminController # rubocop:disable Metrics/ClassLength
    before_action :set_page, only: %i[index search]

    def index
      @subscriptions = current_user
        .subscriptions
        .joins(feed: { taggings: :tag })
        .includes(feed: { taggings: :tag })
        .order(active: :desc, "feeds.name" => :asc)
        .page(@page).per(@pagination_size)
    end

    def new
      @subscription = current_user.subscriptions.new(feed: Feed.new)
    end

    def create
      @service = Subscriptions::CreateSubscription.perform(
        user: current_user,
        name: subscription_params[:name],
        tag_list: subscription_params[:tag_list],
        url: subscription_params[:url],
        description: subscription_params[:description]
      )
      default_subscription = current_user.subscriptions.build(
        feed: Feed.new(name: subscription_params[:name], url: subscription_params[:url], tag_list: subscription_params[:tag_list], description: subscription_params[:description])
      )
      default_subscription.hide_from_main_page = subscription_params[:hide_from_main_page]
      @subscription = @service.subscription || default_subscription

      respond_to do |format|
        if @service.success?
          format.html { redirect_to admin_subscriptions_path, notice: "Added #{@subscription.feed.name}." }
        else
          @subscription.feed = @service.feed
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      @subscription = current_user.subscriptions.find_by(id: params[:id])
    end

    def update
      @service = Subscriptions::UpdateSubscription.perform(
        user: current_user,
        id: params[:id],
        params: subscription_params
      )

      respond_to do |format|
        if @service.success?
          subscription = @service.subscription
          format.html { redirect_to admin_subscriptions_path, notice: "Updated #{subscription.feed.name}." }
        else
          @subscription = @service.subscription
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def subscribe
      @subscription = current_user.subscriptions.new(feed_id: params[:feed_id])
      @subscription.save
      Feeds::FreshFeed.perform(feed_id: @subscription.feed.id) unless @subscription.feed.refresh_at.present?
    end

    def unsubscribe
      @subscription = current_user.subscriptions.find_by(id: params[:subscription_id])
      @subscription.destroy
    end

    def refresh_all
      RefreshSubscriptionsJob.perform_async

      respond_to do |format|
        format.html { redirect_to admin_subscriptions_path, notice: "Subscriptions queued for refresh." }
      end
    end

    def refresh
      subscription = current_user.subscriptions.find_by(id: params[:id])
      unless subscription
        flash[:alert] = "Could not find subscription"
        redirect_to request.referer
        return
      end

      RefreshFeedJob.perform_async(subscription.feed_id)

      respond_to do |format|
        format.html { redirect_to request.referer, notice: "Subscription queued for refresh." }
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

      @subscriptions = current_user
        .subscriptions
        .joins(:feed)
        .includes(feed: { taggings: :tag })
        .where("upper(feeds.name) like ?", "%#{@query.upcase}%")
        .order(active: :desc, "feeds.name" => :asc)
        .page(@page).per(@pagination_size)
      render :index
    end

    private

    def set_page
      @page = params[:page]&.to_i || 1
    end

    def subscription_params
      params.require(:subscription).permit(:name, :tag_list, :url, :description, :hide_from_main_page)
    end
  end
end
