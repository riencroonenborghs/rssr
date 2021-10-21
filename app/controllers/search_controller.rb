class SearchController < ApplicationController
  def create
    set_query
    perform_search
  end

  private

  def set_query
    @query = params[:query]
  end

  def perform_search
    @entries = [] and return if @query.blank?

    title_scope = Entry.where("upper(entries.title) like ?", "%#{@query.upcase}%")
    summary_scope = Entry.where("upper(entries.summary) like ?", "%#{@query.upcase}%")

    if user_signed_in?
      title_scope = title_scope.joins(feed: :user).where("users.id = ?", current_user.id)
      summary_scope = summary_scope.joins(feed: :user).where("users.id = ?", current_user.id)
    end

    @entries = title_scope.or(summary_scope)
  end
end