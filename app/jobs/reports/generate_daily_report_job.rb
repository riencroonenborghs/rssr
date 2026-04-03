# frozen_string_literal: true

module Reports
  class GenerateDailyReportJob < ApplicationJob
    queue_as :rssreader

    def perform(report)
      Reports::GenerateReport.perform(report: report)
    end
  end
end
