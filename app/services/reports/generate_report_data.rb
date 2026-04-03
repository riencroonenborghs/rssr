# frozen_string_literal: true

module Reports
  class GenerateReportData
    include Service

    attr_reader :data, :prompt

    def initialize(report:)
      @report = report
    end

    def perform
      search_entries
      return if failure?

      add_error("Nothing found") and return if @entries.none?
      
      create_prompt
      summarize
    end

    private

    def search_entries
      service = SearchEntries.perform(keywords: @report.keywords)
      if service.success?
        @entries = service.entries.order(published_at: :asc)
        if @report.daily?
          @entries = @entries.where(published_at: Date.yesterday.all_day)
        elsif @report.weekly?
          @entries = @entries.where(published_at: (Date.today - 1.week).all_week)
        end
      end

      errors.merge!(service.errors)
    end

    def create_prompt
      @prompt = ["Create a summary of the following points. Be concise and to the point."].tap do |ret|
        @entries.each do |entry|
          ret << "* #{entry.description}"
        end
      end.join("\n")
    end

    def summarize
      @data = Notegpt::Chat.perform(prompt: @prompt).data
    end
  end
end
