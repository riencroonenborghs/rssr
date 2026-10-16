module Api
  # Summarizes the signed in user's entries matching keywords within a period, using Claude.
  class SummariesController < BaseController
    before_action :authenticate_user!

    rescue_from Summaries::CreateService::Error do |error|
      render json: { error: error.message }, status: :unprocessable_content
    end

    def create
      @result = Summaries::CreateService.call(visible_entries, keywords: params[:keywords], period: params[:period])
    end
  end
end
