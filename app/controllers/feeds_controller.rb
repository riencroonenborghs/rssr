class FeedsController < ApplicationController
  def index
    set_entries
    paged_render
  end

  def by_tag
    set_tag
    set_entries_by_tag
    paged_render
  end

  private

  def set_entries
    @entries = paged_offset_scope do    
      Entry
        .joins(:feed)
        .merge(Feed.active)
        .most_recent_first
    end.page(page)
  end

  def set_tag
    @tag = params[:tag]
  end

  def set_entries_by_tag
    @entries = Entry
      .joins(:feed)
      .merge(Feed.active.tagged_with(@tag))
      .most_recent_first
      .page(page)
  end
end