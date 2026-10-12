class AddImageUrlToRssEntries < ActiveRecord::Migration[8.1]
  class RssEntry < ActiveRecord::Base; end

  # Stands in for a parsed feed entry when backfilling: only the stored summary is available.
  StoredEntry = Struct.new(:summary, :url)

  def up
    add_column :rss_entries, :image_url, :string

    RssEntry.reset_column_information
    RssEntry.where.not(summary: [ nil, "" ]).find_each do |entry|
      image_url = RssEntries::ImageUrlService.call(StoredEntry.new(entry.summary, entry.url))
      entry.update_columns(image_url: image_url) if image_url
    end
  end

  def down
    remove_column :rss_entries, :image_url
  end
end
