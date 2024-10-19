# frozen_string_literal: true

module Filters
  class PgFilterEntries < BaseFilterEntries
    private

    def apply_filter_includes(filter_values:)
      @scope = scope.merge(
        scope.where.not("UPPER(entries.title) LIKE ANY (array[#{filter_values.join(", ")}])")
      )
    end

    def apply_filter_excludes(filter_values:)
      @scope = scope.merge(
        scope.where.not("UPPER(entries.title) NOT LIKE ANY (array[#{filter_values.join(", ")}])")
      )
    end

    def apply_filter_matches(filter_values:)
      @scope = scope.merge(
        scope.where.not("UPPER(entries.title) ~ '#{filter_values.join("|")}'")
      )
    end

    def apply_filter_mismatches(filter_values:)
      @scope = scope.merge(
        scope.where.not("UPPER(entries.title) !~ '#{filter_values.join("|")}'")
      )
    end
  end
end
