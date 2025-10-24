# frozen_string_literal: true

module V2
  class BookmarksController < V2::BaseController
    def create
      unless current_user
        render json: { success: false }, status: 401
        return
      end

      if (bookmark = current_user.bookmarks.find_by(entry_id: params[:entry_id]))
        bookmark.destroy
        render json: { success: true, bookmark: :removed }, status: 200
      else
        bookmark = current_user.bookmarks.create!(entry_id: params[:entry_id])
        render json: { success: true, bookmark: :created }, status: 200
      end
    end
  end
end
