# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :authenticate_user!

  def index
    @filters = current_user.filters.order(value: :asc).page(page).per(32)
  end

  def new
    @filter = Filter.new
  end

  def create
    @filter = current_user.filters.build(filter_params)

    respond_to do |format|
      if @filter.save
        format.html { redirect_to filters_path, notice: "Filter #{@filter.human_readable} added." }
      else
        flash[:alert] = @filter.errors.full_messages.to_sentence
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    filter = current_user.filters.find_by(id: params[:id])
    filter.destroy
    flash[:notice] = "Filter #{filter.human_readable} removed."
    redirect_to filters_path
  end

  private

  def filter_params
    params.require(:filter).permit(:comparison, :value)
  end
end
