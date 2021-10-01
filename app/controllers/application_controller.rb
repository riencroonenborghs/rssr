class ApplicationController < ActionController::Base
  before_action :set_feeds

  private

  def set_feeds
    @feeds = Feed.alphabetically.includes(:entries)
  end

  def paged_render
    if page > 1
      render :page, layout: false
      return
    end
  end
end
