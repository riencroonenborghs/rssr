# frozen_string_literal: true

class FiltersController < ApplicationController
  def index
    @page = params[:page] || 1

    if current_user
      @filters = current_user.filters.order("value asc").page(@page).per(32)
    else
      @filters = Filter.none.page(@page)
    end
  end
end
