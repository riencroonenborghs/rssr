require "rails_helper"

RSpec.describe RssEntries::CreateService do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }
  let(:feed_entry_class) { Struct.new(:entry_id, :title, :url, :summary, :content, :published, :image, keyword_init: true) }

  def feed_entry(**attributes)
    feed_entry_class.new(**attributes)
  end

  describe ".call" do
    it "creates entries with their attributes" do
      published = Time.utc(2026, 10, 1)
      entry = feed_entry(entry_id: "a", title: "A", url: "https://example.com/a", summary: "Sum", published: published)

      described_class.call(feed, [ entry ])

      expect(feed.rss_entries.sole).to have_attributes(
        guid: "a", title: "A", url: "https://example.com/a", summary: "Sum", published_at: published
      )
    end

    it "stores the entry's image" do
      described_class.call(feed, [ feed_entry(entry_id: "a", image: "https://example.com/a.jpg") ])

      expect(feed.rss_entries.sole.image_url).to eq("https://example.com/a.jpg")
    end

    it "adds an image to stored entries that have none" do
      feed.rss_entries.create!(guid: "a")
      feed.rss_entries.create!(guid: "b", image_url: "https://example.com/old.jpg")

      described_class.call(feed, [
        feed_entry(entry_id: "a", image: "https://example.com/a.jpg"),
        feed_entry(entry_id: "b", image: "https://example.com/new.jpg")
      ])

      expect(feed.rss_entries.order(:guid).pluck(:image_url)).to eq([ "https://example.com/a.jpg", "https://example.com/old.jpg" ])
    end

    it "returns the number of entries created" do
      feed.rss_entries.create!(guid: "a")

      expect(described_class.call(feed, [ feed_entry(entry_id: "a"), feed_entry(entry_id: "b") ])).to eq(1)
    end

    it "indexes new entries for full-text search" do
      described_class.call(feed, [ feed_entry(entry_id: "a", title: "Searchable") ])

      expect(RssEntries::SearchService.call(RssEntry.all, "searchable").pluck(:guid)).to eq([ "a" ])
    end

    it "skips entries already stored for the feed" do
      feed.rss_entries.create!(guid: "a", title: "Existing")

      expect { described_class.call(feed, [ feed_entry(entry_id: "a"), feed_entry(entry_id: "b") ]) }
        .to change { feed.rss_entries.count }.by(1)
      expect(feed.rss_entries.find_by(guid: "a").title).to eq("Existing")
    end

    it "stores an entry already stored for another feed" do
      RssFeed.create!(url: "https://example.com/other.xml").rss_entries.create!(guid: "a")

      described_class.call(feed, [ feed_entry(entry_id: "a") ])

      expect(feed.rss_entries.pluck(:guid)).to eq([ "a" ])
    end

    it "ignores duplicates within the same batch" do
      described_class.call(feed, [ feed_entry(entry_id: "a"), feed_entry(entry_id: "a") ])

      expect(feed.rss_entries.count).to eq(1)
    end

    it "falls back to the url as guid and content as summary" do
      described_class.call(feed, [ feed_entry(url: "https://example.com/a", content: "Body") ])

      expect(feed.rss_entries.sole).to have_attributes(guid: "https://example.com/a", summary: "Body")
    end

    it "skips entries without an id or url" do
      described_class.call(feed, [ feed_entry(title: "No id") ])

      expect(feed.rss_entries).to be_empty
    end

    it "logs how many entries are created" do
      feed.rss_entries.create!(guid: "a")
      allow(Rails.logger).to receive(:info)

      described_class.call(feed, [ feed_entry(entry_id: "a"), feed_entry(entry_id: "b") ])

      expect(Rails.logger).to have_received(:info)
        .with("[RssEntries::CreateService] feed=#{feed.id} creating 1 entries (2 in feed, 1 already stored)")
    end
  end
end
