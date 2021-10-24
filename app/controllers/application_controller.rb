class ApplicationController < ActionController::Base
  # feeds
  before_action :set_signed_in_feeds, if: -> { user_signed_in? }
  before_action :set_global_feeds, if: -> { !user_signed_in? }

  before_action :set_offset
  before_action :darkmode?
  
  before_action :tags

  private


  def set_signed_in_feeds
    @feeds = current_user.feeds.alphabetically.includes(:entries)
  end

  def set_global_feeds
    @feeds = Feed.alphabetically.includes(:entries)
  end

  def set_offset
    @offset = params[:ts] ? Offset.to_datetime(offset: params[:ts]) : nil
  end

  def page
    params[:page]&.to_i || 1
  end

  def paged_render
    if page > 1
      render :page, layout: false
      return
    end
  end

  def paged_offset_scope
    scope = yield
    scope = scope.where("entries.created_at <= ?", @offset) if @offset
    scope
  end

  def darkmode?
    @darkmode = Darkmode.darkmode?
  end

  def tags
    loader = LoadTodaysTags.call
    @tags = loader.tags
    @tag_count_by_tag = loader.tag_count_by_tag
    @feeds_by_tag = loader.feeds_by_tag
    @entries_by_tag_by_feed = loader.entries_by_tag_by_feed
  end
end
