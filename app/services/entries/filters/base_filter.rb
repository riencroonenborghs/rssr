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
        when Filter::TAGGED_FILTER
          apply_filter_tagged(filter_values: filter_values)
        end
      end

      def apply_filter_includes(filter_values:)
        raise NotImplementedError
      end

      def apply_filter_tagged(filter_values:)
        raise NotImplementedError
      end
    end
  end
end
