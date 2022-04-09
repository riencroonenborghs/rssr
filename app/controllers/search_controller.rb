class SearchController < ApplicationController
  def create
    set_query
    perform_search
    set_bookmarks
    set_viewed
  end

  private

  def set_query
    @query = params[:query]
  end

  def perform_search
    @entries = [] and return if @query.blank?

    @entries = filtered_scope do
      current_user_scope do
        Entry
          .search(@query)
          .joins(feed: :subscriptions)
          .merge(Subscription.active)
          .most_recent_first
          .limit(100)
      end
    end
  end
end
