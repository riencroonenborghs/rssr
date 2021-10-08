class SearchController < ApplicationController
  def create
    set_feeds
    set_query
    perform_search
  end

  private

  def set_query
    @query = params[:query]
  end

  def perform_search
    @entries = [] and return if @query.blank?

    title_scope = Entry.where("upper(title) like ?", "%#{@query.upcase}%")
    summary_scope = Entry.where("upper(summary) like ?", "%#{@query.upcase}%")

    pp title_scope.or(summary_scope).to_sql

    @entries = title_scope.or(summary_scope)
  end
end