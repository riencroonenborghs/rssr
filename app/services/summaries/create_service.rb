module Summaries
  # Summarizes the entries matching keywords (as search does) published within a period, using the
  # Claude API with the key in ANTHROPIC_API. Only the newest MAX_ENTRIES entries are sent. Returns
  # a Result whose summary is nil when no entries match. The summary is plain text: "## " headings,
  # "- " bullets and paragraphs, citing entries as [n], their position in Result#entries.
  # Raises Summaries::CreateService::Error with a message for the user when it cannot summarize.
  class CreateService < ApplicationService
    class Error < StandardError; end

    Result = Data.define(:summary, :entries, :total)

    PERIODS = { "24h" => 24.hours, "week" => 1.week, "2weeks" => 2.weeks }.freeze
    MAX_ENTRIES = 100
    MODEL = :"claude-opus-5-5"

    SYSTEM_PROMPT = <<~PROMPT.freeze
      You summarize posts from the user's RSS feeds. You are given the keywords the user searched
      for and the matching posts, each numbered like [3]. Write a concise briefing of what the posts
      say about the keywords: group related posts into a few themes, lead with what matters most, and
      point out disagreements or developments between posts. Cite the posts each point is based on by
      their number, e.g. [3] or [3][7]. Use only what the posts say.

      Format the summary as plain text: start with a short overview paragraph, then one section per
      theme with a heading line starting with "## " followed by bullet lines starting with "- ".
      Use no other formatting: no bold, italics, links or tables.
    PROMPT

    def initialize(entries, keywords:, period:)
      @entries = entries
      @keywords = keywords.to_s.strip
      @period = period.to_s
    end

    def call
      raise Error, "Enter one or more keywords" if keywords.scan(/[[:alnum:]]+/).empty?
      raise Error, "Choose a period: #{PERIODS.keys.to_sentence(last_word_connector: ' or ')}" unless PERIODS.key?(period)

      matching = RssEntries::SearchService.call(entries, keywords)
        .where("COALESCE(rss_entries.published_at, rss_entries.created_at) >= ?", PERIODS.fetch(period).ago)
      total = matching.count
      return Result.new(summary: nil, entries: [], total: 0) if total.zero?

      selected = matching.includes(:rss_feed).limit(MAX_ENTRIES).to_a
      Result.new(summary: summarize(selected), entries: selected, total: total)
    end

    private
      attr_reader :entries, :keywords, :period

      def summarize(selected)
        stream = client.beta.messages.stream(
          model: MODEL,
          max_tokens: 16_000,
          output_config: { effort: :medium },
          # On a policy decline, the API retries on its default fallback model.
          betas: [ "server-side-fallback-2026-07-01" ],
          fallbacks: :default,
          system_: SYSTEM_PROMPT,
          messages: [ { role: "user", content: prompt(selected) } ]
        )
        message = stream.accumulated_message
        raise Error, "Claude declined to summarize these posts" if message.stop_reason == :refusal

        message.content.select { |block| block.type == :text }.map(&:text).join.strip
      rescue Anthropic::Errors::AuthenticationError, Anthropic::Errors::PermissionDeniedError
        raise Error, "The Anthropic API key in ANTHROPIC_API was rejected"
      rescue Anthropic::Errors::RateLimitError
        raise Error, "The Anthropic API is rate limiting requests; try again shortly"
      rescue Anthropic::Errors::APIError => e
        Rails.logger.error("[#{self.class.name}] Claude API request failed: #{e.class}: #{e.message}")
        raise Error, "The summary could not be created (#{e.class.name.demodulize})"
      end

      def client
        api_key = ENV["ANTHROPIC_API"].presence or raise Error, "Set ANTHROPIC_API to an Anthropic API key to create summaries"
        Anthropic::Client.new(api_key: api_key)
      end

      def prompt(selected)
        posts = selected.each.with_index(1).map do |entry, number|
          <<~POST
            [#{number}] #{entry.title}
            Feed: #{entry.rss_feed.display_title}
            Published: #{(entry.published_at || entry.created_at).iso8601}
            #{plain_text(entry.summary)}
          POST
        end

        "Keywords: #{keywords}\nPosts from the last #{period_label}:\n\n#{posts.join("\n")}"
      end

      def period_label
        { "24h" => "24 hours", "week" => "week", "2weeks" => "2 weeks" }.fetch(period)
      end

      def plain_text(html)
        Rails::HTML5::FullSanitizer.new.sanitize(html.to_s).squish
      end
  end
end
