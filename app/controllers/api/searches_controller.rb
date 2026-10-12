module Api
  class SearchesController < BaseController
    # Visible entries whose title or summary match q, newest first, a page at a time.
    def show
      render_entries_page(RssEntries::SearchService.call(visible_entries, params[:q]))
    end
  end
end
