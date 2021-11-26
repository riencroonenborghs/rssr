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

    @entries = filtered_scope do
      current_user_scope do
        Entry.where("upper(entries.title) like :query OR upper(entries.summary) like :query", query: "%#{@query.upcase}%").limit(100)
      end
    end
  end
end
