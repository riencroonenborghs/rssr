class ReadLaterEntriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @entries = Entry
      .joins(feed: { subscriptions: :user})
      .joins(:read_later)
      .merge(current_user.read_later_entries)
  end

  def create
    entry = Entry.find_by(id: params[:entry_id])
    return unless entry

    @read_later = current_user.read_later_entries.build(entry_id: entry.id)
    @read_later.save
  end

  def destroy
    @read_later = current_user.read_later_entries.find_by(entry_id: params[:entry_id])
    @read_later.destroy
  end
end
