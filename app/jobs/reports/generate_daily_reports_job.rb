# frozen_string_literal: true

module Reports
  class GenerateDailyReportsJob < ApplicationJob
    queue_as :rssreader

    def perform
      Report.daily.find_each do |report|
        GenerateDailyReportJob.perform_later(report)
      end
    end
  end
end
