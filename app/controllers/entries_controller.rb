class EntriesController < ApplicationController
  def index
    set_feed
    set_entries
    paged_render
  end

  private

  def set_feed
    @feed = Feed.find(params[:feed_id])
  end

  def set_entries
    @entries = @feed.entries.most_recent_first.page(page)
  end  
end