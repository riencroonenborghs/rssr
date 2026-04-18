# frozen_string_literal: true

module Api
  module V1
    class BookmarksController < Api::BaseController
      def index
        @entries = Entry.where(id: current_user.bookmarks.select(:entry_id)).most_recent_first.page(page)
        set_tags_by_entry
        set_viewed_entries
        set_bookmarks
      end

      def create
        bookmark = current_user.bookmarks.create(entry_id: params[:entry_id])
        render json: { bookmark_id: bookmark.id }, status: :ok
      end

      def destroy
        current_user.bookmarks.find_by(entry_id: params[:id])&.destroy
        head :ok
      end
    end
  end
end
