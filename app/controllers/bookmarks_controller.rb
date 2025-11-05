# frozen_string_literal: true

class BookmarksController < ApplicationController
  def index
    @page = params[:page] || 1

    if current_user
      entry_ids = current_user
        .bookmarks
        .select(:entry_id)

      @entries = Entry
        .includes(:bookmarks, feed: { subscriptions: { taggings: :tag } })
        .where(id: entry_ids)
        .order("bookmarks.created_at DESC")
        .page(@page)
    
      set_subscriptions_by_feed_id(feed_ids: @entries.map(&:feed_id))
      set_viewed_ids(entry_ids: @entries.map(&:id))
      set_bookmarked_ids(entry_ids: @entries.map(&:id))

    else
      @entries = Entry.none.page(@page)
    end
  end

  def create
    unless current_user
      render json: { success: false }, status: 401
      return
    end

    if (bookmark = current_user.bookmarks.find_by(entry_id: params[:entry_id]))
      bookmark.destroy
      render json: { success: true, bookmark: :removed }, status: 200
    else
      bookmark = current_user.bookmarks.create!(entry_id: params[:entry_id])
      render json: { success: true, bookmark: :created }, status: 200
    end
  end
end
