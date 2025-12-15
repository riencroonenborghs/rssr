# frozen_string_literal: true

class TagsController < ApplicationController
  def show
    @tag = Tag.find_by(id: params[:id])
    @entries = filtered_scope do
      user_scope do
        subscription_scope = Subscription.none
        subscription_scope = current_user.subscriptions.tagged_with(@tag) if user_signed_in?

        Entry.joins(feed: :subscriptions).tagged_with(@tag).or(
          Entry.joins(feed: :subscriptions).where(subscriptions: { id: subscription_scope.select(:id) })
        ).most_recent_first
      end
    end.page(page)
  end
end
