# frozen_string_literal: true

module Reports
  class GenerateReportData
    include Service

    MODEL = "claude-haiku-4-5"

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
      @prompt = ["Summarize. Be concise. Use bold headings and bullet points. Don't generalize. Don't improvise. Stick to the timeline. Omit timestamps. If unsure, don't report."].tap do |ret|
        @entries.each do |entry|
          ret << "* (#{entry.published_at.iso8601}) #{ActionView::Base.full_sanitizer.sanitize(entry.description)}"
        end
      end.join("\n")
    end

    def summarize
      anthropic = Anthropic::Client.new(
        api_key: ENV["ANTHROPIC_API_KEY"] # This is the default and can be omitted
      )

      message = anthropic.messages.create(
        max_tokens: 1024,
        messages: [{ role: "user", content: @prompt }],
        model: MODEL
      )

      @data = message.content[0].text
    rescue StandardError => e
      errors.merge!(e)
    end
  end
end
