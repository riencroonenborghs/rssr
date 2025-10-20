# frozen_string_literal: true

module Entries
  module Filters
    class BaseFilter
      include Base

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
        # # tagged_with goes a ILIKE across all filter_valuesand is slow as fuck
        # values = filter_values.map { |value| "'#{value}'" }.join(", ")

        # # Find all entry IDs tagged w/ filter_values
        # entry_ids = @scope.select(:id)
        # tagged_entry_ids = ActsAsTaggableOn::Tagging
        #   .joins(:tag)
        #   .where(
        #     taggable_type: "Entry"
        #   )
        #   .where("UPPER(tags.name) NOT LIKE ANY (array[#{values}])")
        #   .select(:taggable_id)
        # # Apply that to the scope
        # entries_tagged_on_entries = @scope.where(id: tagged_entry_ids)

        # # Find all subscriptions tagged w/ filter_values,
        # # get their feed_ids and then apply that to the scope
        # subscription_ids = @user.subscriptions.active.select(:id)
        # tagged_subscriptions_ids = ActsAsTaggableOn::Tagging
        #   .joins(:tag)
        #   .where(
        #     taggable_type: "Subscription"
        #   )
        #   .where("UPPER(tags.name) NOT LIKE ANY (array[#{values}])")
        #   .select(:taggable_id)
        # entries_tagged_on_subscriptions = @scope.where(
        #   feed_id: @user.subscriptions.active.where(id: tagged_subscriptions_ids).select(:feed_id)
        # )

        # @scope = scope.merge(
        #   entries_tagged_on_entries.merge(entries_tagged_on_subscriptions)
        # )
      end
    end
  end
end
