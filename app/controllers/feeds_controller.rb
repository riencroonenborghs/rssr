class FeedsController < ApplicationController
  def index
    set_entries
    set_bookmarks
    set_viewed
    paged_render
  end

  def tagged
    set_tag
    set_entries_tagged
    set_bookmarks
    set_viewed
    paged_render
  end

  def tagged_today
    set_tag
    set_entries_tagged_today
    set_bookmarks
    set_viewed
    paged_render
  end

  private

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        current_user_scope do
          Entry
            .joins(:feed)
            .merge(Feed.active)
            .joins(feed: :subscriptions)
            .merge(Subscription.active)
            .most_recent_first
        end
      end
    end.page(page).per(@pagination_size)
  end

  def set_tag
    @tag = params[:tag]
  end

  def set_entries_tagged
    scope = filtered_scope do
      current_user_scope do
        Entry
          .includes(feed: :taggings)
          .merge(Feed.active.tagged_with(@tag))
          .joins(feed: [:subscriptions, :taggings])
          .merge(Subscription.active)
          .most_recent_first
      end
    end
    @entries = scope.page(page).per(@pagination_size)
  end

  def set_entries_tagged_today
    scope = filtered_scope do
      current_user_scope do
        Entry
          .joins(:feed)
          .merge(Feed.active.tagged_with(@tag))
          .joins(feed: :subscriptions)
          .merge(Subscription.active)
          .most_recent_first
          .today
      end
    end
    @entries = scope.page(page).per(@pagination_size)
  end
end
