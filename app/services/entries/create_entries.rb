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

      # ActiveRecord::Base.transaction do
        create_entries
      # end
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
          guid: entry_to_create.guid,
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

      guids = parsed_entries.map(&:guid)
      existing_guids = @feed.entries.where(guid: guids).pluck(:guid)
      guids_to_create = (guids - existing_guids)
      parsed_entries.select do |entry|
        guids_to_create.include?(entry.guid)
      end
    end
  end
end
