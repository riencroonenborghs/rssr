# frozen_string_literal: true

module Api
  module V1
    class SubscriptionsController < Api::BaseController
      def index
        @subscriptions = current_user.subscriptions.includes(:feed).order(feeds: { title: :asc })
      end

      def create
        service = Subscriptions::CreateSubscription.perform(
          user: current_user,
          url: subscription_params[:url],
          title: subscription_params[:title],
          get_title_from_url: subscription_params[:get_title_from_url] == "true",
          tag_names: subscription_params[:tags]
        )

        if service.success?
          render json: { subscription: { id: service.subscription.id, feed: { id: service.subscription.feed.id, title: service.subscription.feed.title, url: service.subscription.feed.url } } }, status: :ok
        else
          render json: { errors: service.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def destroy
        subscription = current_user.subscriptions.find_by(id: params[:id])
        return head :not_found unless subscription

        subscription.destroy
        head :ok
      end

      private

      def subscription_params
        params.require(:subscription).permit(:url, :title, :get_title_from_url, :tags)
      end
    end
  end
end
