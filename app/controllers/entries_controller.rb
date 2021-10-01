class EntriesController < ApplicationController
  def index
    set_all_entries
    paged_render
  end

  private

  def set_all_entries
    @all_entries = Entry
      .joins(:feed)
      .merge(Feed.active)
      .most_recent_first
      .page(page)
  end

  def page
    params[:page]&.to_i || 1
  end
end