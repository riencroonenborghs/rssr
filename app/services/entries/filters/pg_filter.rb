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
    end
  end
end
