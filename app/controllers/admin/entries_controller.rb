module Admin
  class EntriesController < ApplicationController
    before_action :authenticate_user!

    def visit
      current_user.feeds.map(&:visit!)
      redirect_url = params[:root] ? root_path : admin_feeds_url

      respond_to do |format|
        format.html { redirect_to redirect_url, notice: "Queued visiting all feeds." }
      end
    end
  end
end
