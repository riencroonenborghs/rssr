module RssEntries
  # Narrows entries to those whose title or summary contain every word of the query, using the
  # rss_entries_fts full-text index (stemmed, case-insensitive). The last word also matches as a
  # prefix, so results follow along while typing. A query without words matches nothing.
  class SearchService < ApplicationService
    def initialize(entries, query)
      @entries = entries
      @query = query.to_s
    end

    def call
      words = query.scan(/[[:alnum:]]+/)
      return entries.none if words.empty?

      # Quoting each word makes it a plain term, never full-text query syntax.
      terms = words.map { |word| %("#{word}") }
      terms[-1] = "#{terms[-1]}*"
      entries.where("rss_entries.id IN (SELECT rowid FROM rss_entries_fts WHERE rss_entries_fts MATCH ?)", terms.join(" "))
    end

    private
      attr_reader :entries, :query
  end
end
