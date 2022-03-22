class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def index
    @entries = Entry.joins(feed: { subscriptions: :user }).joins(:read_later).merge(current_user.read_later_entries.unread).order("read_later_entries.created_at" => :asc)
  end

  def create
    entry = Entry.find_by(id: params[:entry_id])
    return unless entry

    # rubocop:disable Style/IfUnlessModifier
    unless (@read_later = current_user.read_later_entries.find_by(entry_id: entry.id))
      @read_later = current_user.read_later_entries.create!(entry_id: entry.id)
    end
    # rubocop:enable Style/IfUnlessModifier
    @read_later.unread!
    @read_later_count = current_user.read_later_entries.unread.count
  end

  def destroy
    @remove_from_list = request.referer == all_bookmarks_url
    @read_later = current_user.read_later_entries.find_by(entry_id: params[:entry_id])
    @read_later.read!
    @read_later_count = current_user.read_later_entries.unread.count
  end
end
