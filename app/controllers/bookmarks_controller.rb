# frozen_string_literal: true

class BookmarksController < ApplicationController
  def index
    redirect_to(root_path, alert: "Not signed in") and return unless user_signed_in?

    @entries = Entry.where(id: current_user.bookmarks.select(:entry_id)).most_recent_first.page(page)
  end

  def create
    redirect_to(root_path, alert: "Not signed in") and return unless user_signed_in?

    current_user.bookmarks.create(entry_id: params[:entry_id])
    head :ok
  end

  def destroy
    redirect_to(root_path, alert: "Not signed in") and return unless user_signed_in?

    current_user.bookmarks.find_by(entry_id: params[:id])&.destroy
    head :ok
  end
end
