class FeedsController < ApplicationController
  def index
    set_entries
    paged_render
  end

  def tagged
    set_tag
    set_entries_tagged
    paged_render
  end

  def tagged_today
    set_tag
    set_entries_tagged_today
    paged_render
  end

  private

  def set_entries
    @entries = offset_scope do
      filtered_scope do
        current_user_scope do
          Entry
            .joins(:feed)
            .merge(Feed.active)
            .most_recent_first
        end
      end
    end.page(page)
  end

  def set_tag
    @tag = params[:tag]
  end

  def set_entries_tagged
    scope = filtered_scope do
      current_user_scope do
        Entry
          .joins(:feed)
          .merge(Feed.active.tagged_with(@tag))
          .most_recent_first
      end
    end
    @entries = scope.page(page)
  end

  def set_entries_tagged_today
    scope = filtered_scope do
      current_user_scope do
        Entry
          .joins(:feed)
          .merge(Feed.active.tagged_with(@tag))
          .most_recent_first
          .last_24h
      end
    end
    @entries = scope.page(page)
  end
end
