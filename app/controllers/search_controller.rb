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

    title_scope = current_user_scope do
      filtered_scope do
        Entry.where("upper(entries.title) like ?", "%#{@query.upcase}%")
      end
    end

    summary_scope = Entry.where("upper(entries.summary) like ?", "%#{@query.upcase}%")

    @entries = title_scope.or(summary_scope)
  end
end