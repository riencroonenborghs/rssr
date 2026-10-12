module RssEntries
  # Returns the entries of a user's subscribed feeds, newest first, hiding entries whose title or
  # summary match any of the user's filters. Keyword filters use the rss_entries_fts full-text
  # index; regexp filters use the REGEXP function from config/initializers/sqlite_regexp.rb.
  class FilteredService < ApplicationService
    def initialize(user)
      @user = user
    end

    def call
      keyword_filters, regexp_filters = Filter.where(user: user).partition(&:keyword?)

      entries = RssEntry.where(rss_feed_id: user.subscriptions.select(:rss_feed_id))
      entries = without_keyword_matches(entries, keyword_filters)
      entries = without_regexp_matches(entries, regexp_filters)
      entries.newest_first
    end

    private
      attr_reader :user

      # One FTS5 query matching any filter, where a filter matches when all of its words appear:
      # ("apple" AND "watch") OR ("rust")
      def without_keyword_matches(entries, filters)
        return entries if filters.empty?

        query = filters.map { |filter| "(#{filter.keywords.map { |word| %("#{word}") }.join(" AND ")})" }.join(" OR ")
        entries.where("rss_entries.id NOT IN (SELECT rowid FROM rss_entries_fts WHERE rss_entries_fts MATCH ?)", query)
      end

      def without_regexp_matches(entries, filters)
        filters.reduce(entries) do |scope, filter|
          scope.where.not("rss_entries.title REGEXP :pattern OR rss_entries.summary REGEXP :pattern", pattern: filter.value)
        end
      end
  end
end
