class ApplicationController < ActionController::Base
  before_action :set_feeds

  private

  def set_feeds
    @feeds = Feed.alphabetically.includes(:entries)
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
end
