# frozen_string_literal: true

module Api
  module V1
    class FiltersController < Api::BaseController
      def index
        @filters = current_user.filters.order("lower(value) asc").page(page)
      end

      def create
        filter = current_user.filters.build(filter_params)
        if filter.save
          render json: { filter_id: filter.id }, status: :ok
        else
          render json: { errors: filter.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def destroy
        filter = current_user.filters.find_by(id: params[:id])
        filter.destroy

        head :ok
      end

      private

      def filter_params
        params.require(:filter).permit(:comparison, :value)
      end
    end
  end
end
