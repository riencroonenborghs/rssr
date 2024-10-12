# frozen_string_literal: true

module Admin
  class SubscriptionsController < AdminController # rubocop:disable Metrics/ClassLength
    before_action :set_page, only: %i[index search]

    def index
      @subscriptions = current_user
        .subscriptions
        .joins(feed: { subscriptions: { taggings: :tag } })
        .includes(feed: { subscriptions: { taggings: :tag } })
        .order(active: :desc, "feeds.name" => :asc)
        .page(@page).per(28)
    end

    def new
      @feed = Feed.new
      @subscription = current_user.subscriptions.new(feed: @feed)
      @step = 1

      render :new
    end

    def step_1 # rubocop:disable Naming/VariableNumber
      @feed = Feed.new url: subscription_params[:url]
      @subscription = current_user.subscriptions.new(feed: @feed)
      @service = FindRssFeeds.perform(url: subscription_params[:url])

      respond_to do |format|
        if @service.success?
          @step = 2
          format.html { render :new }
        else
          @step = 1
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def step_2 # rubocop:disable Naming/VariableNumber
      @feed = Feed.new url: subscription_params[:url], rss_url: subscription_params[:rss_url]
      @subscription = current_user.subscriptions.new(feed: @feed)
      @service = GuessFeedDetails.perform(feed: @feed)
      @step = 3

      respond_to do |format|
        format.html { render :new }
      end
    end

    def step_3 # rubocop:disable Naming/VariableNumber
      @service = CreateSubscription.perform(
        user: current_user,
        url: subscription_params[:url],
        rss_url: subscription_params[:rss_url],
        name: subscription_params[:name],
        tag_list: subscription_params[:tag_list],
        description: subscription_params[:description],
        hide_from_main_page: subscription_params[:hide_from_main_page]
      )

      @feed = @service.feed || service.default_feed
      @subscription = @service.subscription || @service.default_subscription

      respond_to do |format|
        if @service.success?
          format.html { redirect_to admin_subscriptions_path, notice: "Subscribed to #{@feed.name}" }
        else
          @step = 3
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def create
      case subscription_params[:step].to_i
      when 1
        step_1
      when 2
        step_2
      when 3
        step_3
      end
    end

    def edit
      @subscription = current_user.subscriptions.find_by(id: params[:id])
    end

    def update
      @service = UpdateSubscription.perform(
        user: current_user,
        id: params[:id],
        params: subscription_params
      )

      respond_to do |format|
        if @service.success?
          subscription = @service.subscription
          format.html { redirect_to admin_subscriptions_path, notice: "Updated #{subscription.feed.name}" }
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

      respond_to do |format|
        format.html { redirect_to admin_subscriptions_path, notice: "Unsubscribed from #{@subscription.feed.name}." }
      end
    end

    def refresh_all
      RefreshSubscriptionsJob.perform_later

      respond_to do |format|
        format.html { redirect_to admin_subscriptions_path, notice: "Subscriptions queued" }
      end
    end

    def refresh
      subscription = current_user.subscriptions.find_by(id: params[:id])
      unless subscription
        flash[:alert] = "Could not find subscription"
        redirect_to request.referer
        return
      end

      RefreshFeedJob.perform_later(subscription.feed)

      respond_to do |format|
        format.html { redirect_to request.referer, notice: "Subscription queued" }
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
        .includes(feed: { subscriptions: { taggings: :tag } })
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
      params.require(:subscription).permit(:step, :url, :rss_url, :name, :tag_list, :description, :hide_from_main_page)
    end
  end
end
