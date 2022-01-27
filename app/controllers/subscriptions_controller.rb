class SubscriptionsController < ApplicationController
  def today # rubocop:disable Metrics/MethodLength
    @entries = offset_scope do
      filtered_scope do
        scope = Entry
                .includes(:viewed_by)
                .most_recent_first
                .today
                .joins(feed: { subscriptions: :user })
                .distinct
        scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
        scope
      end
    end.page(page).per(@pagination_size)

    paged_render
  end

  private

  def set_page
    @page = param
  end
end
