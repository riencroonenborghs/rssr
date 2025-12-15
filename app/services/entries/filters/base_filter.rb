# frozen_string_literal: true

module Entries
  module Filters
    class BaseFilter
      include Service

      attr_reader :scope

      def initialize(user:, scope:)
        @user = user
        @scope = scope
      end

      def perform
        return unless @user.filters.any?

        @user.filters.group_by(&:comparison).each do |comparison, filters|
          apply_filters(comparison: comparison, filters: filters)
        end
      end

      private

      def apply_filters(comparison:, filters:)
        filter_values = filters.map(&:value).map(&:upcase)

        case comparison
        when Filter::INCLUDES_FILTER
          apply_filter_includes(filter_values: filter_values)
        when Filter::EXCLUDES_FILTER
          apply_filter_excludes(filter_values: filter_values)
        when Filter::MATCHES_FILTER
          apply_filter_matches(filter_values: filter_values)
        when Filter::MISMATCHES_FILTER
          apply_filter_mismatches(filter_values: filter_values)
        when Filter::TAGGED_FILTER
          apply_filter_tagged(filter_values: filter_values)
        end
      end

      def apply_filter_includes(filter_values:)
        raise NotImplementedError
      end

      def apply_filter_excludes(filter_values:)
        raise NotImplementedError
      end

      def apply_filter_matches(filter_values:)
        raise NotImplementedError
      end

      def apply_filter_mismatches(filter_values:)
        raise NotImplementedError
      end

      def apply_filter_tagged(filter_values:)
        entry_ids = Tagging
          .joins(:tag)
          .where(taggable_type: "Entry")
          .where(tags: { name: filter_values.map(&:upcase) })
          .select(:taggable_id)
        @scope = @scope.where.not(id: entry_ids)
      end
    end
  end
end
