# frozen_string_literal: true

module Entries
  class WatchedEntries
    include Base

    attr_reader :scope, :watches, :page, :pagination_size, :offset

    def initialize(scope:, watches:, page: nil, pagination_size: nil, offset: nil)
      @scope = scope
      @watches = watches
      @page = page
      @pagination_size = pagination_size
      @offset = offset
    end

    def perform
      return unless watches.any?

      watches.each { |watch| add_watch_scope(watch: watch) }

      @scope = scope.most_recent_first.distinct.page(page) if page
      @scope = scope.per(pagination_size) if pagination_size
      @scope = scope.where("entries.created_at <= ?", offset) if offset
    end

    private

    def add_watch_scope(watch:)
      values = watch.value.upcase.split(",")

      case watch.watch_type
      when Watch::ENTRY_TITLE
        values.each { |title| add_entry_title_scope(title: title) }
      when Watch::ENTRY_DESCRIPTION
        values.each { |description| add_entry_description_scope(description: description) }
      when Watch::SUBSCRIPTION_TAG
        values.each { |tag| add_subscription_tag_scope(tag: tag) }
      when Watch::ENTRY_TAG
        values.each { |tag| add_entry_tag_scope(tag: tag) }
      end
    end

    def add_entry_title_scope(title:)
      @scope = scope.where("upper(entries.title) like ?", "%#{title.upcase}%")
    end

    def add_entry_description_scope(description:)
      @scope = scope.where("upper(entries.description) like ?", "%#{description.upcase}%")
    end

    def add_subscription_tag_scope(tag:)
      @scope = scope
        .joins(feed: { subscriptions: { taggings: :tag } })
        .includes([:feed])
        .merge(Subscription.tagged_with(tag.upcase))
    end

    def add_entry_tag_scope(tag:)
      @scope = scope
        .joins(feed: { subscriptions: { taggings: :tag } })
        .includes([:feed])
        .tagged_with(tag.upcase)
    end
  end
end
