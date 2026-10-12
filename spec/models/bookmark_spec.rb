require "rails_helper"

# == Schema Information
#
# Table name: bookmarks
# Database name: primary
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  rss_entry_id :integer          not null
#  user_id      :integer          not null
#
# Indexes
#
#  index_bookmarks_on_rss_entry_id              (rss_entry_id)
#  index_bookmarks_on_user_id                   (user_id)
#  index_bookmarks_on_user_id_and_rss_entry_id  (user_id,rss_entry_id) UNIQUE
#
# Foreign Keys
#
#  rss_entry_id  (rss_entry_id => rss_entries.id)
#  user_id       (user_id => users.id)
#
RSpec.describe Bookmark do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }
  let(:entry) { feed.rss_entries.create!(guid: "a") }

  it "allows a user to bookmark an entry only once" do
    described_class.create!(user: user, rss_entry: entry)

    expect { described_class.create!(user: user, rss_entry: entry) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "is removed when the entry is destroyed" do
    described_class.create!(user: user, rss_entry: entry)

    entry.destroy!

    expect(described_class.count).to eq(0)
    expect(user.reload).to be_persisted
  end

  it "is removed when the entry's feed is destroyed" do
    described_class.create!(user: user, rss_entry: entry)

    feed.destroy!

    expect(described_class.count).to eq(0)
  end
end
