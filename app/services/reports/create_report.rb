# frozen_string_literal: true

module Reports
  class CreateReport
    include Service

    DAY_REPORT = :day
    WEEK_REPORT = :week

    attr_reader :data

    def initialize(keywords:, report_type: DAY_REPORT)
      @keywords = keywords
      @report_type = report_type
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
      service = SearchEntries.perform(keywords: @keywords)
      if service.success?
        case @report_type
        when DAY_REPORT
          @entries = service.entries.order(published_at: :asc).where(published_at: Date.yesterday.all_day)
        when WEEK_REPORT
          @entries = service.entries.order(published_at: :asc).where(published_at: (Date.today - 1.week).all_week)
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
