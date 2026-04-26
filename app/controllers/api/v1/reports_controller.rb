# frozen_string_literal: true

module Api
  module V1
    class ReportsController < Api::BaseController
      def index
        @reports = current_user.reports.page(page)
      end

      def create
        @report = current_user.reports.build(report_params)
        if @report.save
          render :create, status: :ok
        else
          render json: { errors: @report.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def update
        @report = current_user.reports.find(params[:id])
        if @report.update(report_params)
          render :update, status: :ok
        else
          render json: { errors: @report.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      end

      def destroy
        report = current_user.reports.find_by(id: params[:id])
        report.destroy

        head :ok
      end

      private

      def report_params
        params.require(:report).permit(:keywords)
      end
    end
  end
end
