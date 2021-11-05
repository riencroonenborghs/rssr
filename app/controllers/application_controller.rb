class ApplicationController < ActionController::Base
  before_action :set_offset
  # before_action :darkmode?
  before_action :mobile?

  before_action :tags, if: -> { mobile? }

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

  def tags
    loader = LoadTodaysTags.call
    @tags = loader.tags
    @tag_count_by_tag = loader.tag_count_by_tag
    @feeds_by_tag = loader.feeds_by_tag
    @entries_by_tag_by_feed = loader.entries_by_tag_by_feed
  end

  def mobile?
    @mobile = browser.device.mobile?
  end
end
