class ApplicationController < ActionController::Base
  before_action :set_offset
  # before_action :darkmode?
  before_action :mobile?

  before_action :set_today_count
  before_action :set_read_later_count
  before_action :set_subscription_count

  def set_today_count
    @today_count = filtered_scope do
      scope = Entry
              .includes(:viewed_by)
              .most_recent_first
              .today
              .joins(feed: { subscriptions: :user })
              .distinct
      scope = scope.merge(User.where(id: current_user.id)) if user_signed_in?
      scope
    end.count
  end

  def set_read_later_count
    @read_later_count = 0 and return unless user_signed_in?

    @read_later_count = current_user.read_later_entries.count
  end

  def set_subscription_count
    @subscription_count = 0 and return unless user_signed_in?

    @subscription_count = current_user.subscriptions.count
  end

  private

  def set_offset
    @offset = params[:ts] ? Offset.to_datetime(offset: params[:ts]) : nil
  end

  def page
    params[:page]&.to_i || 1
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

    scope = FilterEngine::Engine.call(user: current_user, scope: scope).scope # rubocop:disable Style/RedundantAssignment
    scope
  end

  def darkmode?
    @darkmode = Darkmode.darkmode?
  end

  def mobile?
    @mobile = browser.device.mobile?
  end
end
