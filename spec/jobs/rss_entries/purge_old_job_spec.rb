require "rails_helper"

RSpec.describe RssEntries::PurgeOldJob do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  def entry(guid, created_at:)
    feed.rss_entries.create!(guid: guid, created_at: created_at)
  end

  it "deletes entries older than two weeks" do
    old_entry = entry("old", created_at: 15.days.ago)

    described_class.perform_now

    expect(RssEntry.exists?(old_entry.id)).to be(false)
  end

  it "keeps entries younger than two weeks" do
    recent_entry = entry("recent", created_at: 13.days.ago)

    described_class.perform_now

    expect(RssEntry.exists?(recent_entry.id)).to be(true)
  end

  it "deletes old entries that users have read" do
    read_entry = entry("read", created_at: 15.days.ago)
    user.mark_read(read_entry)

    described_class.perform_now

    expect(RssEntry.exists?(read_entry.id)).to be(false)
    expect(RssEntryRead.count).to eq(0)
  end

  it "keeps old entries that are bookmarked" do
    bookmarked_entry = entry("bookmarked", created_at: 15.days.ago)
    user.bookmark(bookmarked_entry)

    described_class.perform_now

    expect(RssEntry.exists?(bookmarked_entry.id)).to be(true)
  end

  it "is scheduled daily" do
    recurring = Rails.application.config_for(:recurring, env: "production")

    expect(recurring[:purge_old_rss_entries]).to include(class: described_class.name, schedule: "every day at 3am")
  end
end
