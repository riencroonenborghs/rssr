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

    name_scope = filtered_scope do
      current_user_scope do
        Entry.where("upper(entries.name) like ?", "%#{@query.upcase}%")
      end
    end

    summary_scope = Entry.where("upper(entries.summary) like ?", "%#{@query.upcase}%")

    @entries = name_scope.or(summary_scope)
  end
end
