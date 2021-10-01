class FeedsController < ApplicationController
  def entries
    set_feed
    set_entries
    paged_render
  end

  private

  def set_feed
    @feed = Feed.find(params[:id])
  end

  def set_entries
    @entries = @feed.entries.most_recent_first.page(page)
  end

  def page
    params[:page]&.to_i || 1
  end
end