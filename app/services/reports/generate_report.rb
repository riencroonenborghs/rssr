# frozen_string_literal: true

module Reports
  class GenerateReport
    include Service

    attr_reader :generated_report

    def initialize(report:)
      @report = report
    end

    def perform
      generate_report_data
      return if failure?

      @generated_report = @report.generated_reports.build(summary: @data, prompt: @prompt)
      return if @generated_report.save

      errors.merge!(@generated_report.errors)
    end

    private

    def generate_report_data
      service = GenerateReportData.perform(report: @report)
      if service.success?
        @data = service.data.join(" ")
        @prompt = service.prompt
        return
      end

      errors.merge!(service.errors)
    end
  end
end
