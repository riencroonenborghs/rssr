# frozen_string_literal: true

class GeneratedReportsController < ApplicationController
  before_action :authenticate_user!

  def show
    @generated_report = GeneratedReport.where(report_id: current_user.report_ids).find_by(id: params[:id])
    @report = @generated_report.report
  end
end
