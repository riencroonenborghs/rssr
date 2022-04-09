class SubscriptionsController < ApplicationController
  def today
    set_entries
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        scope = Entry
                .includes(:viewed_entries)
                .most_recent_first
                .today
                .joins(feed: { subscriptions: :user })
                .merge(Subscription.active)
        scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
        scope
      end
    end.page(page).per(@pagination_size)
  end

  def set_page
    @page = param
  end
end
