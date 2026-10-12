require "rails_helper"

# == Schema Information
#
# Table name: subscriptions
# Database name: primary
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  rss_feed_id :integer          not null
#  user_id     :integer          not null
#
# Indexes
#
#  index_subscriptions_on_rss_feed_id              (rss_feed_id)
#  index_subscriptions_on_user_id                  (user_id)
#  index_subscriptions_on_user_id_and_rss_feed_id  (user_id,rss_feed_id) UNIQUE
#
# Foreign Keys
#
#  rss_feed_id  (rss_feed_id => rss_feeds.id)
#  user_id      (user_id => users.id)
#
RSpec.describe Subscription do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }

  it "allows a user to subscribe to a feed only once" do
    described_class.create!(user: user, rss_feed: feed)

    expect { described_class.create!(user: user, rss_feed: feed) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "is removed when the feed is destroyed" do
    described_class.create!(user: user, rss_feed: feed)

    feed.destroy!

    expect(described_class.count).to eq(0)
    expect(user.reload).to be_persisted
  end
end
