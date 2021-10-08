class FeedsController < ApplicationController
  def index
    set_entries
    paged_render
  end

  private

  def set_entries
    @entries = Entry
      .joins(:feed)
      .merge(Feed.active)
      .most_recent_first
      .page(page)
  end
end