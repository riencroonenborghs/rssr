# frozen_string_literal: true

module Entries
  class CreateSubredditEntries
    include Base

    validates :feed, :entries, presence: true

    attr_reader :rss_items

    def initialize(feed:, feed_data:)
      @feed = feed
      @entries = feed_data.dig(:data, :children) || []
    end

    def perform
      @rss_items = entries_to_add.map do |entry|
        description = entry_description(entry)
        title = entry_title(entry, description)

        hash = {
          title: title,
          link: entry_link(entry),
          published_at: entry_published_at(entry),
          description: description,
          guid: entry_guid(entry)
        }

        image = entry.dig(:data, :thumbnail)
        hash[:image] = image if image.match(/http/)

        hash
      end
    end

    private

    attr_reader :feed, :entries

    def entries_to_add
      new_guids = entries.map { |entry| entry_guid(entry) }.compact
      existing_guids = feed.entries.where(guid: new_guids).pluck(:guid)

      new_guids -= existing_guids
      entries.select { |entry| new_guids.include?(entry_guid(entry)) }
    end

    def entry_description(entry)
      ActionController::Base.helpers.strip_tags(entry.dig(:data, :selftext))
    end

    def entry_title(entry, _description)
      entry.dig(:data, :title)
    end

    def entry_link(entry)
      entry.dig(:data, :url)
    end

    def entry_published_at(entry)
      created_utc = entry.dig(:data, :created_utc)
      Time.at(created_utc)
    rescue StandardError
      nil
    end

    def entry_guid(entry)
      entry.dig(:data, :id)
    end
  end
end
