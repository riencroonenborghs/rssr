module Api
  # Bookmarks and unbookmarks a single entry for the signed in user.
  class EntryBookmarksController < BaseController
    before_action :authenticate_user!

    def create
      current_user.bookmark(entry)
      head :no_content
    end

    def destroy
      current_user.unbookmark(entry)
      head :no_content
    end

    private
      def entry
        viewable_entries.find(params[:entry_id])
      end
  end
end
