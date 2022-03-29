class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def index
    @entries = Entry.joins(feed: { subscriptions: :user }).joins(:bookmarks).merge(current_user.bookmarks.unread).order("bookmarks.created_at" => :asc)
  end

  def create
    entry = Entry.find_by(id: params[:entry_id])
    return unless entry

    # rubocop:disable Style/IfUnlessModifier
    unless (@bookmark = current_user.bookmarks.find_by(entry_id: entry.id))
      @bookmark = current_user.bookmarks.create!(entry_id: entry.id)
    end
    # rubocop:enable Style/IfUnlessModifier
    @bookmark.unread!
    @bookmarks_count = current_user.bookmarks.unread.count
  end

  def destroy
    @remove_from_list = request.referer == all_bookmarks_url
    @bookmark = current_user.bookmarks.find_by(entry_id: params[:entry_id])
    @bookmark.read!
    @bookmarks_count = current_user.bookmarks.unread.count
  end
end
