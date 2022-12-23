class WatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :my_group?, only: %i[show]
  before_action :set_watches_by_group

  def index
    first_group_id = current_user.watches.select(:group_id).distinct.pluck(:group_id).first
    redirect_to watches_group_path(group_id: first_group_id) if first_group_id
  end

  def show
    @watches = current_user.watches.where(group_id: params[:group_id])
    @entries = Entries::WatchedEntries.perform(
      watches: @watches,
      scope: base_scope.dup,
      page: page,
      pagination_size: @pagination_size,
      offset: @offset
    ).scope

    set_bookmarks
    set_viewed

    paged_render
  end

  private

  def base_scope
    @base_scope ||= Entry.joins(feed: { subscriptions: :user }).where("users.id = ?", current_user.id)
  end

  def my_group?
    return true if current_user.watches.exists?(group_id: params[:group_id])

    flash[:alert] = "Not your group"
    redirect_to action: :index
    false
  end
end
