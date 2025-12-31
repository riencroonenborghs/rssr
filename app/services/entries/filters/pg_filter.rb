# frozen_string_literal: true

module Entries
  module Filters
    class PgFilter < BaseFilter
      private

      def apply_filter_includes(filter_values:)
        values = filter_values.map { |value| "'%#{value}%'" }
        values = values.join(", ")

        @scope = @scope.merge(
          @scope.where.not("UPPER(entries.title) LIKE ANY (array[#{values}])")
        )
      end

      def apply_filter_excludes(filter_values:)
        values = filter_values.map { |value| "'%#{value}%'" }
        values = values.join(", ")

        @scope = @scope.merge(
          @scope.where.not("UPPER(entries.title) NOT LIKE ANY (array[#{values}])")
        )
      end

      def apply_filter_matches(filter_values:)
        @scope = @scope.merge(
          @scope.where.not("UPPER(entries.title) ~ '#{filter_values.join('|')}'")
        )
      end

      def apply_filter_mismatches(filter_values:)
        @scope = @scope.merge(
          @scope.where.not("UPPER(entries.title) !~ '#{filter_values.join('|')}'")
        )
      end
    end
  end
end
