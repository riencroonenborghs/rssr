class FeedsController < ApplicationController
  before_action :authenticate_user!
  
  def tagged
    set_tag
    set_entries_tagged
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_tag
    @tag = params[:tag]&.upcase
  end

  def set_entries_tagged
    scope = filtered_scope do
      current_user_scope do
        Entry
          .includes(feed: { subscriptions: { taggings: :tag } })
          .merge(Subscription.active.tagged_with(@tag))
          .joins(feed: { subscriptions: :taggings })
          .most_recent_first
          .distinct
      end
    end
    @entries = scope.page(page).per(@pagination_size)
  end
end
