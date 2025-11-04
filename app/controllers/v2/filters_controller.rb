# frozen_string_literal: true

module V2
  class FiltersController < V2::BaseController
    def index
      @page = params[:page] || 1

      if current_user
        @filters = current_user.filters.order("value asc").page(@page).per(32)
      else
        @filters = Filter.none.page(@page)
      end
    end
  end
end
