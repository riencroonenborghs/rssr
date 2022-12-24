class FeedsController < ApplicationController
  def tagged
    set_tag
    set_entries_tagged
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_tag
    @tag = params[:tag]
  end

  def set_entries_tagged
    scope = filtered_scope do
      current_user_scope do
        Entry
          .includes(feed: :taggings)
          .merge(Feed.active.tagged_with(@tag))
          .joins(feed: %i[subscriptions taggings])
          .merge(Subscription.active)
          .most_recent_first
          .distinct
      end
    end
    @entries = scope.page(page).per(@pagination_size)
  end
end
