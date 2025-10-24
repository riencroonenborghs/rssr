# frozen_string_literal: true

module Entries
  class BuildEntries
    include Base

    attr_reader :entries

    def initialize(feed:, feed_data:)
      @feed = feed
      @entries = feed_data.entries
    end

    def perform
      @entries = entries_to_add.map do |entry|
        BuildEntry.perform(entry: entry).hash
      end
    end

    private

    def entries_to_add
      new_guids = @entries.map { |entry| Entry.parse_guid(entry) }.compact
      existing_guids = @feed.entries.where(guid: new_guids).pluck(:guid)

      new_guids -= existing_guids
      @entries.select { |entry| new_guids.include?(Entry.parse_guid(entry)) }
    end
  end
end
