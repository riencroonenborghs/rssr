class ApplicationController < ActionController::Base
  before_action :set_offset
  before_action :darkmode?
  before_action :mobile?
  before_action :set_pagination_size
  before_action :set_watches_by_group, if: -> { mobile? }

  def mobile?
    browser.device.mobile?
  end
  helper_method :mobile?

  def set_bookmarks
    @bookmarks = user_signed_in? ? Bookmark.unread.where(user_id: current_user.id).map(&:entry_id) : []
  end

  def set_viewed
    entry_ids = @entries_by_tag ? @entries_by_tag.values.flatten.map(&:id).uniq : @entries.map(&:id).uniq
    @viewed = user_signed_in? ? ViewedEntry.where(user_id: current_user.id, entry_id: entry_ids).map(&:entry_id) : []
  end

  private

  def set_offset
    @offset = params[:ts] ? Offset.to_datetime(offset: params[:ts]) : nil
  end

  def page
    params[:page]&.to_i || 1
  end

  def set_pagination_size
    @pagination_size = mobile? ? 20 : 24
  end

  def paged_render
    render :page, layout: false and return if page > 1
  end

  def offset_scope
    scope = yield
    scope = scope.where("entries.created_at <= ?", @offset) if @offset
    scope
  end

  def current_user_scope
    scope = yield
    scope = scope.joins(feed: { subscriptions: :user }).where("users.id = ?", current_user.id) if user_signed_in?
    scope
  end

  def filtered_scope
    scope = yield
    return scope unless user_signed_in?

    scope = FilterEntries.perform(user: current_user, scope: scope).scope # rubocop:disable Style/RedundantAssignment

    scope
  end

  def darkmode?
    @darkmode = Darkmode.darkmode?
  end
  helper_method :darkmode?

  def set_watches_by_group
    @watches_by_group = current_user ? current_user.watches.select(:group_id).distinct.pluck(:group_id) : {}
  end
end
