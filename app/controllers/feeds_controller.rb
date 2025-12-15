# frozen_string_literal: true

class FeedsController < ApplicationController
  include FeedEntries

  def show
    set_feed

    unless @feed
      flash[:alert] = "Feed not found"
      redirect_to root_path
      return
    end

    set_feed_entries
  end

  private

  def set_feed_id
    @feed_id = params[:id]
  end
end
