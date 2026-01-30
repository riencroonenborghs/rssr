# frozen_string_literal: true

module Entries
  module Filters
    class Sqlite3Filter < BaseFilter
      private

      def apply_filter_includes(filter_values:)
        fts5 = fts5_entry_scope(scope: EntryTitle.none, filter_values: filter_values) do |scope, next_scope|
          scope.or(next_scope)
        end

        @scope = @scope.merge(scope.where.not(id: fts5))
      end

      def apply_filter_excludes(filter_values:)
        fts5 = fts5_entry_scope(scope: EntryTitle.none, filter_values: filter_values) do |scope, next_scope|
          scope.merge(next_scope)
        end

        @scope = @scope.merge(scope.where(id: fts5))
      end

      def apply_filter_matches(filter_values:)
        # TODO
      end

      def apply_filter_mismatches(filter_values:)
        # TODO
      end

      def apply_filter_tagged(filter_values:)
        fts5 = fts5_tag_scope(scope: EntryTitle.none, filter_values: filter_values) do |scope, next_scope|
          scope.or(next_scope)
        end

        @scope = @scope.merge(scope.where.not(id: fts5))
      end

      def fts5_entry_scope(scope:, filter_values:)
        filter_values.map { |x| x.split(/[|-]/) }.flatten.each do |value|
          next_scope = EntryTitle.where("entry_titles MATCH ?", "title:#{value}*")
          scope = yield(scope, next_scope)
        end
        scope.select(:entry_id)
      end

      def fts5_tag_scope(scope:, filter_values:)
        filter_values.map { |x| x.split(/[|-]/) }.flatten.each do |value|
          next_scope = SearchableTag
            .where("searchable_tags MATCH ?", "tag_name:\"#{value.upcase}\"*")
            .where("taggable_type = ?", "Entry")
          scope = yield(scope, next_scope)
        end
        scope.select(:taggable_id)
      end
    end
  end
end
