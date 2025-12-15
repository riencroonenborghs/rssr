# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @subscriptions = current_user.subscriptions.includes(:feed).order(feeds: { title: :asc }).page(page).per(12)
  end

  def new
    @subscription = FormObjects::Subscription.new
  end

  def create
    service = Subscriptions::CreateSubscription.perform(
      user: current_user,
      url: subscription_params[:url],
      title: subscription_params[:title],
      get_title_from_url: subscription_params[:get_title_from_url],
      tag_names: subscription_params[:tag_names]
    )

    respond_to do |format|
      if service.success?
        format.html { redirect_to subscriptions_path, notice: "Subscribed to #{service.subscription.feed.title}." }
      else
        @subscription = FormObjects::Subscription.from_params(subscription_params)
        flash[:alert] = service.errors.full_messages.to_sentence
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    subscription = current_user.subscriptions.find_by(id: params[:id])
    subscription.destroy
    flash[:notice] = "Subscription #{subscription.feed.title} removed."
    redirect_to subscriptions_path
  end

  private

  def subscription_params
    params.require(:subscription).permit(:url, :title, :get_title_from_url, :tag_names)
  end
end
