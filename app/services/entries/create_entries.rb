# frozen_string_literal: true

module Entries
  class CreateEntries
    include Service

    def initialize(feed:)
      @feed = feed
    end

    def perform
      get_feed_data
      return unless success?

      create_entries
    end

    private

    def get_feed_data
      service = Feeds::GetFeedData.perform(url: @feed.url)
      if service.success?
        @feed_data = service.feed_data
        return
      end

      copy_errors(service.errors)
    end

    def create_entries
      entries_to_create.each do |entry_to_create|
        built_entry = @feed.entries.build(
          uuid: entry_to_create.uuid,
          description: entry_to_create.description,
          title: entry_to_create.title,
          link: entry_to_create.link,
          published_at: entry_to_create.published_at,
          image: entry_to_create.image
        )
        next unless built_entry.save

        built_entry.add_tags(entry_to_create.tag_list)
      end

      copy_errors(@feed.errors)
    end

    def entries_to_create
      parsed_entries = @feed_data.entries.map do |entry|
        EntryParser.new(entry: entry)
      end

      uuids = parsed_entries.map(&:uuid)
      existing_uuids = @feed.entries.where(uuid: uuids).pluck(:uuid)
      uuids_to_create = (uuids - existing_uuids)
      parsed_entries.select do |entry|
        uuids_to_create.include?(entry.uuid)
      end
    end
  end
end
