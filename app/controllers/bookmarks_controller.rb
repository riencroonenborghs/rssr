# frozen_string_literal: true

class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def index
    @entries = Entry
      .includes(feed: { subscriptions: { taggings: :tag } })
      .where(id: current_user.bookmarks.select(:entry_id))
      .order(current_user.bookmarks.order(created_at: :desc).pluck(:entry_id).map { |id| "id = #{id} DESC" })
      .page(page).per(@pagination_size)

    return paged_render if params.key?(:page) # rubocop:disable Style/RedundantReturn
  end

  def create
    entry = Entry.find_by(id: params[:entry_id])
    return unless entry

    # rubocop:disable Style/IfUnlessModifier
    unless (@bookmark = current_user.bookmarks.find_by(entry_id: entry.id)) # rubocop:disable Style/GuardClause
      @bookmark = current_user.bookmarks.create!(entry_id: entry.id)
    end
    # rubocop:enable Style/IfUnlessModifier
  end

  def destroy
    @bookmark = current_user.bookmarks.find_by(entry_id: params[:entry_id])
    @bookmark.destroy
  end
end
