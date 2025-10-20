# frozen_string_literal: true

module Entries
  module Filters
    class Sqlite3Filter < BaseFilter
      private

      def apply_filter_includes(filter_values:)
        sql = filter_values.map { |filer_value| "UPPER(entries.title) LIKE '%#{filer_value}%'" }.join(" OR ")
        @scope = @scope.merge(scope.where.not(sql))
      end

      def apply_filter_excludes(filter_values:)
        sql = filter_values.map { |filer_value| "UPPER(entries.title) NOT LIKE '%#{filer_value}%'" }.join(" OR ")
        @scope = @scope.merge(scope.where.not(sql))
      end

      def apply_filter_matches(filter_values:)
      end

      def apply_filter_mismatches(filter_values:)
      end
    end
  end
end
