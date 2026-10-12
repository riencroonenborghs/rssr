require "rails_helper"

RSpec.describe Imports::LegacyDatabaseService do
  let(:dir) { Dir.mktmpdir }
  let(:path) { File.join(dir, "legacy.sqlite3") }
  let(:password_digest) { User.new(password: "legacy-password").encrypted_password }

  after { FileUtils.remove_entry(dir) }

  # The previous version's schema, reduced to the columns the import reads.
  def build_legacy_database
    db = SQLite3::Database.new(path)
    db.execute_batch(<<~SQL)
      CREATE TABLE users (id INTEGER PRIMARY KEY, email VARCHAR NOT NULL, encrypted_password VARCHAR NOT NULL,
        remember_created_at DATETIME, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, name TEXT);
      CREATE TABLE feeds (id INTEGER PRIMARY KEY, url VARCHAR NOT NULL, title VARCHAR NOT NULL, active BOOLEAN NOT NULL,
        refresh_at DATETIME, created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, error TEXT);
      CREATE TABLE entries (id INTEGER PRIMARY KEY, feed_id INTEGER NOT NULL, uuid VARCHAR NOT NULL, link VARCHAR NOT NULL,
        title VARCHAR NOT NULL, description VARCHAR, published_at DATETIME NOT NULL, image VARCHAR,
        created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL);
      CREATE TABLE subscriptions (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, feed_id INTEGER NOT NULL,
        created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL, active BOOLEAN NOT NULL);
      CREATE TABLE bookmarks (id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL, entry_id INTEGER NOT NULL,
        created_at DATETIME NOT NULL, updated_at DATETIME NOT NULL);
    SQL
    now = "2026-01-01 10:00:00"
    db.execute("INSERT INTO users VALUES (7, 'legacy@example.com', ?, NULL, ?, ?, 'Legacy')", [ password_digest, now, now ])
    db.execute("INSERT INTO users VALUES (8, 'existing@example.com', 'other-digest', NULL, ?, ?, NULL)", [ now, now ])
    db.execute("INSERT INTO feeds VALUES (3, 'https://example.com/feed.xml', 'Legacy feed', 1, NULL, ?, ?, NULL)", [ now, now ])
    db.execute("INSERT INTO feeds VALUES (4, 'https://example.com/other.xml', 'Other feed', 0, NULL, ?, ?, 'HTTP 404')", [ now, now ])
    db.execute(<<~SQL, [ now, now ])
      INSERT INTO entries VALUES
        (10, 3, 'guid-1', 'https://example.com/1', 'First', '<p>Hello</p>', '2025-12-31 09:00:00', 'https://example.com/1.jpg', ?, ?)
    SQL
    db.execute("INSERT INTO entries VALUES (11, 3, 'guid-1', 'https://example.com/dup', 'Duplicate guid', NULL, '2025-12-31 09:00:00', NULL, ?, ?)", [ now, now ])
    db.execute("INSERT INTO entries VALUES (12, 4, 'guid-2', 'https://example.com/2', 'Second', NULL, '2025-12-30 09:00:00', 'data:x', ?, ?)", [ now, now ])
    db.execute("INSERT INTO subscriptions VALUES (1, 7, 3, ?, ?, 1), (2, 7, 4, ?, ?, 0)", [ now, now, now, now ])
    db.execute("INSERT INTO bookmarks VALUES (1, 7, 12, ?, ?)", [ now, now ])
    db.close
  end

  before { build_legacy_database }

  it "imports users, feeds, entries, subscriptions and bookmarks" do
    counts = described_class.call(path)

    expect(counts).to eq(users: [ 2, 2 ], feeds: [ 2, 2 ], entries: [ 2, 3 ], subscriptions: [ 1, 1 ], bookmarks: [ 1, 1 ])

    user = User.find_by!(email: "legacy@example.com")
    expect(user.valid_password?("legacy-password")).to be(true)

    feed = RssFeed.find_by!(url: "https://example.com/feed.xml")
    expect(feed).to have_attributes(title: "Legacy feed", active: true)
    expect(RssFeed.find_by!(url: "https://example.com/other.xml")).to have_attributes(active: false, error: "HTTP 404")

    expect(feed.rss_entries.sole).to have_attributes(
      guid: "guid-1", url: "https://example.com/1", title: "First", summary: "<p>Hello</p>",
      image_url: "https://example.com/1.jpg", published_at: Time.utc(2025, 12, 31, 9)
    )
    expect(RssEntry.find_by!(guid: "guid-2").image_url).to be_nil

    expect(user.rss_feeds).to eq([ feed ])
    expect(user.bookmarked_rss_entries.pluck(:guid)).to eq([ "guid-2" ])
  end

  it "keeps records that already exist and can be run again" do
    existing = User.create!(email: "existing@example.com", password: "current-password")
    RssFeed.create!(url: "https://example.com/feed.xml", title: "Current title")

    described_class.call(path)
    counts = described_class.call(path)

    expect(counts).to eq(users: [ 0, 2 ], feeds: [ 0, 2 ], entries: [ 0, 3 ], subscriptions: [ 0, 1 ], bookmarks: [ 0, 1 ])
    expect(existing.reload.valid_password?("current-password")).to be(true)
    expect(RssFeed.find_by!(url: "https://example.com/feed.xml").title).to eq("Current title")
    expect(RssEntry.count).to eq(2)
  end

  it "makes imported entries searchable" do
    described_class.call(path)

    expect(RssEntries::SearchService.call(RssEntry.all, "hello").pluck(:guid)).to eq([ "guid-1" ])
  end

  it "does not change the source database" do
    expect { described_class.call(path) }.not_to(change { [ File.mtime(path), File.size(path) ] })
    expect(Dir.children(dir)).to eq([ "legacy.sqlite3" ])
  end

  it "refuses a missing database or the current one" do
    expect { described_class.call(File.join(dir, "missing.sqlite3")) }.to raise_error(ArgumentError, /No database/)
    current = ActiveRecord::Base.connection_db_config.database
    expect { described_class.call(current) }.to raise_error(ArgumentError, /current database/)
  end
end
