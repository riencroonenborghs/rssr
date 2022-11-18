class ApplicationController < ActionController::Base
  before_action :set_offset
  before_action :darkmode?
  before_action :mobile?
  before_action :set_pagination_size

  # before_action :set_today_count
  # before_action :set_yesterday_count
  # before_action :set_bookmarks_count
  # before_action :set_subscription_count
  # before_action :set_filters_count
  # before_action :set_watches_count
  # before_action :set_watches_entries_count

  def set_today_count
    @today_count = filtered_scope do
      scope = Entry
              .includes(:viewed_entries)
              .most_recent_first
              .today
              .joins(feed: { subscriptions: :user })
              .distinct
      scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
      scope
    end.count
  end

  def set_yesterday_count
    @yesterday_count = filtered_scope do
      scope = Entry
              .includes(:viewed_entries)
              .most_recent_first
              .yesterday
              .joins(feed: { subscriptions: :user })
              .distinct
      scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
      scope
    end.count
  end

  def set_bookmarks_count
    @bookmarks_count = 0 and return unless user_signed_in?

    @bookmarks_count = current_user.bookmarks.unread.count
  end

  def set_subscription_count
    @subscription_count = 0 and return unless user_signed_in?

    @subscription_count = current_user.subscriptions.count
  end

  def set_filters_count
    @filters_count = 0 and return unless user_signed_in?

    @filters_count = current_user.filters.count
  end

  def set_watches_count
    @watches_count = 0 and return unless user_signed_in?

    @watches_count = current_user.watches.select(:group_id).distinct.count
  end

  def set_watches_entries_count
    @watches_entries_count = 0 and return unless user_signed_in?

    scope = Entry.joins(feed: { subscriptions: :user }).where("users.id = ?", current_user.id)

    @watches_entries_count = current_user.watches.group_by(&:group_id).sum do |_, group|
      WatchesService.call(watches: group, scope: scope.dup).scope.count
    end
  end

  def mobile?
    browser.device.mobile?
  end
  helper_method :mobile?

  def set_bookmarks
    @bookmarks = user_signed_in? ? Bookmark.unread.where(user_id: current_user.id).map(&:entry_id) : []
  end

  def set_viewed
    entry_ids = if @entries_by_tag
      @entries_by_tag.values.flatten.map(&:id).uniq
    else
      @entries.map(&:id).uniq
    end
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

    scope = FilterService.call(user: current_user, scope: scope).scope # rubocop:disable Style/RedundantAssignment

    scope
  end

  def darkmode?
    @darkmode = false # Darkmode.darkmode?
  end
  helper_method :darkmode?
end
