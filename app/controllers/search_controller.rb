# frozen_string_literal: true

class SearchController < ApplicationController
  before_action :authenticate_user!

  def new
    @search = FormObjects::Search.new
  end

  def create
    @search = FormObjects::Search.from_params(search_params)

    @entries = user_scope do
      Entry
        .most_recent_first
        .joins(feed: :subscriptions)
        .where(id: EntryTitle.where("entry_titles MATCH ?", @search.query).select(:entry_id))
    end.page(page)
  end

  private

  def search_params
    params.require(:search).permit(:query)
  end
end
