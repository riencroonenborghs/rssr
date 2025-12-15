# frozen_string_literal: true

class EntriesController < ApplicationController
  include FeedEntries

  def show
    # Only load when there's a full page reload instead of a turbo page load
    unless request.headers["x-turbo-request-id"]
      set_feed

      unless @feed
        flash[:alert] = "Feed not found"
        redirect_to root_path
        return
      end

      set_feed_entries
    end

    @entry = Entry.includes(:feed).find_by(id: params[:id])
    unless @entry
      flash[:alert] = "Entry not found"
      redirect_to root_path
      return
    end

    current_user.viewed_entries.create(entry_id: @entry.id) if user_signed_in?
  end

  private

  def set_feed_id
    @feed_id = params[:feed_id]
  end
end
