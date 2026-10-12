module RssEntries
  # Stores parsed Feedjira entries for a feed in one statement: new ones are inserted, and stored
  # ones only gain an image if they have none (entries stored before images were extracted).
  # Returns the number of entries created.
  class CreateService < ApplicationService
    def initialize(rss_feed, feed_entries)
      @rss_feed = rss_feed
      @feed_entries = feed_entries
    end

    def call
      rows = feed_entries.map { |entry| attributes_for(entry) }
        .select { |entry| entry[:guid].present? }
        .uniq { |entry| entry[:guid] }
      return 0 if rows.empty?

      existing = rss_feed.rss_entries.where(guid: rows.pluck(:guid)).count
      created = rows.size - existing
      Rails.logger.info(
        "[#{self.class.name}] feed=#{rss_feed.id} creating #{created} entries " \
        "(#{feed_entries.size} in feed, #{existing} already stored)"
      )

      RssEntry.upsert_all(
        rows,
        unique_by: %i[rss_feed_id guid],
        on_duplicate: Arel.sql("image_url = COALESCE(rss_entries.image_url, excluded.image_url)")
      )
      created
    end

    private
      attr_reader :rss_feed, :feed_entries

      def attributes_for(entry)
        {
          rss_feed_id: rss_feed.id,
          guid: entry.entry_id.presence || entry.url.presence,
          title: entry.title,
          url: entry.url,
          summary: entry.summary.presence || entry.content,
          published_at: entry.published,
          image_url: RssEntries::ImageUrlService.call(entry)
        }
      end
  end
end
