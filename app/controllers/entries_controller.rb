class EntriesController < ApplicationController
  def index
    set_feed
    set_entries
    paged_render
  end

  def day
    set_feed
    set_day_entries
    paged_render
  end

  private

  def set_feed
    @feed = Feed.find(params[:feed_id])
  end

  def set_entries
    @entries = paged_offset_scope do    
      @feed
        .entries
        .most_recent_first
    end.page(page)
  end

  def set_day_entries
    @entries = paged_offset_scope do    
      @feed
        .entries
        .most_recent_first
        .last_24h
    end.page(page)
  end
end