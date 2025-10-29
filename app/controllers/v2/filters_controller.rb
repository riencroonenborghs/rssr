# frozen_string_literal: true

module V2
  class FiltersController < V2::BaseController
    def index
      if current_user
        @page = params[:page] || 1
        @filters = current_user.filters.order("comparison asc, upper(value) asc").page(@page).per(32)
      else
        @filters = Filter.none
      end
    end
  end
end
