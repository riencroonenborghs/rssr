require "rails_helper"

RSpec.describe RssFeeds::FetchAllJob do
  it "enqueues a fetch job for each active feed" do
    active_feeds = Array.new(2) { |i| RssFeed.create!(url: "https://example.com/#{i}.xml") }
    inactive_feed = RssFeed.create!(url: "https://example.com/inactive.xml", active: false)

    described_class.perform_now

    active_feeds.each do |feed|
      expect(RssFeeds::FetchJob).to have_been_enqueued.with(feed)
    end
    expect(RssFeeds::FetchJob).not_to have_been_enqueued.with(inactive_feed)
  end

  it "is scheduled every 30 minutes" do
    recurring = Rails.application.config_for(:recurring, env: "production")

    expect(recurring[:fetch_all_rss_feeds]).to include(class: described_class.name, schedule: "every 30 minutes")
  end
end
