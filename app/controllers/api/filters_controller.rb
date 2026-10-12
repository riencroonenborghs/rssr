module Api
  # Lists, adds and removes the signed in user's filters.
  class FiltersController < BaseController
    before_action :authenticate_user!

    def index
      @filters = current_user.filters.order(:kind, :value)
    end

    def create
      @filter = current_user.filters.create!(params.permit(:kind, :value))
      render :create, status: :created
    end

    def destroy
      current_user.filters.find(params[:id]).destroy!
      head :no_content
    end
  end
end
