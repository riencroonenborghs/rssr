# frozen_string_literal: true

module Filters
  class BaseFilterEntries
    include Base

    attr_reader :user, :scope

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def perform
      return unless user.filters.any?

      user.filters.group_by(&:comparison).each do |comparison, filters|
        apply_filters(comparison, filters)
      end
    end

    private

    def apply_filters(comparison, filters)
      filter_values = filters.map(&:value).map(&:upcase)

      case comparison
      when "includes"
        apply_filter_includes(filter_values: filter_values)
      when "excludes"
        apply_filter_excludes(filter_values: filter_values)
      when "matches"
        apply_filter_matches(filter_values: filter_values)
      when "mismatches"
        apply_filter_mismatches(filter_values: filter_values)
      when "tagged"
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
      entries_tagged_with_scope = scope.tagged_with(filter_values, exclude: true)
      subscriptions_tagged_with_scope = scope.where(
        feed_id: @user.subscriptions.active.tagged_with(filter_values, exclude: true).select(:feed_id)
      )
      @scope = scope.merge(
        entries_tagged_with_scope.merge(subscriptions_tagged_with_scope)
      )
    end
  end
end
