# frozen_string_literal: true

module Entries
  class FilterEntries
    include Base

    attr_reader :user, :scope

    def initialize(user:, scope:)
      @user = user
      @scope = scope
    end

    def perform
      return unless user.filters.any?

      @scope = scope.merge(
        generate_includes_filters
      ).merge(
        generate_excludes_filters
      ).merge(
        generate_matches_filters
      ).merge(
        generate_mismatches_filters
      )
    end

    private

    attr_reader :filters

    def generate_filter_string(comparison)
      user
        .filters
        .where(comparison: comparison)
        .select(:value)
        .pluck(:value)
        .map { |value| "'%#{value.upcase}%'" }
        .join(", ")
    end

    def generate_filter_re(comparison)
      user
        .filters
        .where(comparison: comparison)
        .select(:value)
        .pluck(:value)
        .map(&:upcase)
        .join("|")
    end

    def generate_includes_filters
      filters = generate_filter_string("includes")
      return scope unless filters.present?

      scope.where.not("upper(entries.title) like any (array[#{filters}])")
    end

    def generate_excludes_filters
      filters = generate_filter_string("excludes")
      return scope unless filters.present?

      scope.where.not("upper(entries.title) not like any (array[#{filters}])")
    end

    def generate_matches_filters
      filters = generate_filter_re("matches")
      return scope unless filters.present?

      scope.where.not("upper(entries.title) ~ '#{filters}'")
    end

    def generate_mismatches_filters
      filters = generate_filter_re("mismatches")
      return scope unless filters.present?

      scope.where.not("upper(entries.title) !~ '#{filters}'")
    end
  end
end
