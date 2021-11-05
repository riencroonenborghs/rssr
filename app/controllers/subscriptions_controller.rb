class SubscriptionsController < ApplicationController
  def today
    @entries = offset_scope do
      filtered_scope do
        scope = Entry
          .most_recent_first
          .today
          .joins(feed: { subscriptions: :user })
        scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
        scope
      end
    end.page(page)

    paged_render
  end

  private

  def set_page
    @page = param
  end
end
