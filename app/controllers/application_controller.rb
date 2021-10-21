class ApplicationController < ActionController::Base
  before_action :set_feeds
  before_action :set_offset
  before_action :darkmode?

  private

  def set_feeds
    user_signed_in? ? set_current_user_feeds : set_global_feeds
  end

  def set_current_user_feeds
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
end
