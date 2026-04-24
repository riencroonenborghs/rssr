# frozen_string_literal: true

module Reports
  class SearchEntries
    include Service

    attr_reader :entries

    def initialize(keywords:)
      @keywords = keywords
    end

    def perform
      @entries = Entry
        .most_recent_first
        .joins(feed: :subscriptions)
        .where(id: build_query.select(:entry_id))
    end

    private

    def build_query
      kws = @keywords.dup
      kw = kws.pop

      EntryTitle.where("entry_titles MATCH ?", kw).tap do |query|
        kws.map do |kw|
          query = query.where("entry_titles MATCH ?", kw)
        end
      end
    end
  end
end
