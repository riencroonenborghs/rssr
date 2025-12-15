# frozen_string_literal: true

module Entries
  module Filters
    class Sqlite3Filter < BaseFilter
      private

      def apply_filter_includes(filter_values:)
        fts = EntryTitle.where("entry_titles MATCH ?", ored(filter_values)).select(:entry_id)
        @scope = @scope.merge(scope.where.not(id: fts))
      end

      def apply_filter_excludes(filter_values:)
        fts = EntryTitle.where("entry_titles MATCH ?", ored(filter_values)).select(:entry_id)
        @scope = @scope.merge(scope.where(id: fts))
      end

      def apply_filter_matches(filter_values:)
        # fts = EntryTitle.where("entry_titles MATCH ?", ored(filter_values)).select(:entry_id)
        # @scope = @scope.merge(scope.where.not(id: fts))
      end

      def apply_filter_mismatches(filter_values:)
        # fts = EntryTitle.where("entry_titles MATCH ?", ored(filter_values)).select(:entry_id)
        # @scope = @scope.merge(scope.where(id: fts))
      end

      def ored(filter_values)
        filter_values.map { |x| x.split(/[\|-]/) }.flatten.join(" OR ")
      end
    end
  end
end
