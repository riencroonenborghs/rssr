module Api
  class ReadsController < BaseController
    before_action :authenticate_user!

    # Marks a subscribed entry as read.
    def create
      current_user.mark_read(viewable_entries.find(params[:entry_id]))
      head :no_content
    end
  end
end
