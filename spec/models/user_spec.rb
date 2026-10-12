require "rails_helper"

# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
RSpec.describe User do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }

  describe "#subscribe" do
    it "subscribes the user to the feed" do
      user.subscribe(feed)

      expect(user.rss_feeds).to eq([ feed ])
      expect(feed.users).to eq([ user ])
    end

    it "does nothing when already subscribed" do
      user.subscribe(feed)

      expect { user.subscribe(feed) }.not_to change(Subscription, :count)
    end
  end

  describe "#unsubscribe" do
    it "removes the subscription" do
      user.subscribe(feed)

      user.unsubscribe(feed)

      expect(user.rss_feeds.reload).to be_empty
    end

    it "does nothing when not subscribed" do
      expect { user.unsubscribe(feed) }.not_to raise_error
    end
  end

  describe "#subscribed?" do
    it "is true only when subscribed to the feed" do
      expect(user.subscribed?(feed)).to be(false)

      user.subscribe(feed)

      expect(user.subscribed?(feed)).to be(true)
    end
  end

  describe "bookmarks" do
    let(:entry) { feed.rss_entries.create!(guid: "a") }

    it "bookmarks an entry" do
      user.bookmark(entry)

      expect(user.bookmarked_rss_entries).to eq([ entry ])
    end

    it "does nothing when the entry is already bookmarked" do
      user.bookmark(entry)

      expect { user.bookmark(entry) }.not_to change(Bookmark, :count)
    end

    it "removes a bookmark" do
      user.bookmark(entry)

      user.unbookmark(entry)

      expect(user.bookmarked_rss_entries.reload).to be_empty
    end

    it "does nothing when unbookmarking an entry that is not bookmarked" do
      expect { user.unbookmark(entry) }.not_to raise_error
    end

    it "knows whether an entry is bookmarked" do
      expect(user.bookmarked?(entry)).to be(false)

      user.bookmark(entry)

      expect(user.bookmarked?(entry)).to be(true)
    end
  end

  describe "reads" do
    let(:entry) { feed.rss_entries.create!(guid: "a") }

    it "marks an entry as read once" do
      2.times { user.mark_read(entry) }

      expect(user.rss_entry_reads.count).to eq(1)
      expect(user.read?(entry)).to be(true)
    end

    it "is unread until marked as read" do
      expect(user.read?(entry)).to be(false)
    end
  end

  it "removes subscriptions and bookmarks but keeps feeds and entries when destroyed" do
    entry = feed.rss_entries.create!(guid: "a")
    user.subscribe(feed)
    user.bookmark(entry)

    user.destroy!

    expect(Subscription.count).to eq(0)
    expect(Bookmark.count).to eq(0)
    expect(entry.reload).to be_persisted
    expect(feed.reload).to be_persisted
  end
end
