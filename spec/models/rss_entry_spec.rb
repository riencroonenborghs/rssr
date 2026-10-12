require "rails_helper"

# == Schema Information
#
# Table name: rss_entries
# Database name: primary
#
#  id           :integer          not null, primary key
#  guid         :string           not null
#  image_url    :string
#  published_at :datetime
#  summary      :text
#  title        :string
#  url          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  rss_feed_id  :integer          not null
#
# Indexes
#
#  index_rss_entries_on_rss_feed_id           (rss_feed_id)
#  index_rss_entries_on_rss_feed_id_and_guid  (rss_feed_id,guid) UNIQUE
#
# Foreign Keys
#
#  rss_feed_id  (rss_feed_id => rss_feeds.id)
#
RSpec.describe RssEntry do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }

  def fts_ids(query)
    sql = described_class.sanitize_sql([ "SELECT rowid FROM rss_entries_fts WHERE rss_entries_fts MATCH ?", query ])
    described_class.connection.select_values(sql)
  end

  describe "full-text index" do
    it "indexes new entries" do
      entry = feed.rss_entries.create!(guid: "a", title: "Apple", summary: "Banana")

      expect(fts_ids("apple")).to eq([ entry.id ])
      expect(fts_ids("banana")).to eq([ entry.id ])
    end

    it "reindexes updated entries" do
      entry = feed.rss_entries.create!(guid: "a", title: "Apple")

      entry.update!(title: "Cherry")

      expect(fts_ids("apple")).to be_empty
      expect(fts_ids("cherry")).to eq([ entry.id ])
    end

    it "removes bulk-deleted entries" do
      feed.rss_entries.create!(guid: "a", title: "Apple")

      described_class.delete_all

      expect(fts_ids("apple")).to be_empty
    end
  end
end
