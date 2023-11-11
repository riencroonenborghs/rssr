# frozen_string_literal: true

class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def index
    entry_ids = current_user.bookmarks.order(created_at: :desc).select(:entry_id).pluck(:entry_id)

    @entries = Entry
      .includes(feed: { subscriptions: { taggings: :tag } })
      .where(id: entry_ids)
      .page(page).per(@pagination_size)

    @entries = @entries.sort_by do |entry|
      entry_ids.index(entry.id)
    end

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
