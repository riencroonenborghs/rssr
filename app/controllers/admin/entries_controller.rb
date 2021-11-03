module Admin
  class EntriesController < AdminController
    def visit
      current_user.feeds.map(&:visit!)
      redirect_url = params[:root] ? root_path : admin_subscriptions_url

      respond_to do |format|
        format.html { redirect_to redirect_url, notice: "Queued visiting all feeds." }
      end
    end
  end
end
