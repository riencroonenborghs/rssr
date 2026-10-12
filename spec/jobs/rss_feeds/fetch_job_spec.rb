require "rails_helper"

RSpec.describe RssFeeds::FetchJob do
  include ActiveJob::TestHelper

  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }

  it "fetches the feed" do
    allow(RssFeeds::FetchService).to receive(:call)

    described_class.perform_now(feed)

    expect(RssFeeds::FetchService).to have_received(:call).with(feed)
  end

  it "is discarded when the feed no longer exists" do
    allow(RssFeeds::FetchService).to receive(:call)
    described_class.perform_later(feed)
    feed.destroy!

    expect { perform_enqueued_jobs }.not_to raise_error
    expect(RssFeeds::FetchService).not_to have_received(:call)
  end
end
