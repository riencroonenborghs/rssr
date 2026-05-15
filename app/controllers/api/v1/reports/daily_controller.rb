# frozen_string_literal: true

module Api
  module V1
    module Reports
      class DailyController < Api::BaseController
        def index
          @daily_reports = GeneratedReport
            .includes(:report)
            .where(report_id: params[:report_id])
            .order(created_at: :desc)
        end

        def show
          @daily_report = GeneratedReport
            .includes(:report)
            .where(report_id: current_user.reports.daily.select(:id))
            .find_by(id: params[:id])
        end
      end
    end
  end
end
