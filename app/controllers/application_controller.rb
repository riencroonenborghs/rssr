# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_offset
  before_action :mobile?
  before_action :set_pagination_size

  def mobile?
    browser.device.mobile?
  end
  helper_method :mobile?

  private

  def set_offset
    @offset = params[:ts] ? Offset.to_datetime(offset: params[:ts]) : nil
  end

  def page
    params[:page]&.to_i || 1
  end

  def set_pagination_size
    @pagination_size = 30
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

    scope = Entries::FilterEntries.perform(user: current_user, scope: scope).scope # rubocop:disable Style/RedundantAssignment

    scope
  end
end
