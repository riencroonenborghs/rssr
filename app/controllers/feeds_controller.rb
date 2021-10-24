class FeedsController < ApplicationController
  def index
    set_entries
    paged_render
  end

  def tagged
    set_tag
    set_entries_tagged
    paged_render
  end

  def tagged_today
    set_tag
    set_entries_tagged_today
    paged_render
  end

  private

  def set_entries
    @entries = paged_offset_scope do
      scope = Entry
        .joins(:feed)
        .merge(Feed.active)
        .most_recent_first
      scope = scope.joins(feed: :user).where("users.id = ?", current_user.id) if user_signed_in?
      scope
    end.page(page)
  end

  def set_tag
    @tag = params[:tag]
  end

  def set_entries_tagged
    scope = Entry
      .joins(:feed)
      .merge(Feed.active.tagged_with(@tag))
      .most_recent_first
    scope = scope.joins(feed: :user).where("users.id = ?", current_user.id) if user_signed_in?
    @entries = scope.page(page)
  end

  def set_entries_tagged_today
    scope = Entry
      .joins(:feed)
      .merge(Feed.active.tagged_with(@tag))
      .most_recent_first
      .last_24h
    scope = scope.joins(feed: :user).where("users.id = ?", current_user.id) if user_signed_in?
    @entries = scope.page(page)
  end
end