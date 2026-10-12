require "rails_helper"

RSpec.describe RssFeeds::FetchService do
  let(:url) { "https://example.com/feed.xml" }
  let(:feed) { RssFeed.create!(url: url) }

  def rss(guids)
    items = guids.map do |guid|
      <<~XML
        <item>
          <guid>#{guid}</guid><title>Title #{guid}</title>
          <link>https://example.com/#{guid}</link><description>Summary #{guid}</description>
          <pubDate>Thu, 01 Oct 2026 00:00:00 +0000</pubDate>
        </item>
      XML
    end
    <<~XML
      <?xml version="1.0"?>
      <rss version="2.0"><channel>
        <title>Example</title><link>https://example.com</link><description>Example</description>
        #{items.join}
      </channel></rss>
    XML
  end

  describe ".call" do
    it "stores entries from an RSS feed" do
      stub_request(:get, url).to_return(body: rss(%w[a b]))

      described_class.call(feed)

      expect(feed.rss_entries.order(:guid).pluck(:guid)).to eq(%w[a b])
      entry = feed.rss_entries.find_by(guid: "a")
      expect(entry).to have_attributes(title: "Title a", url: "https://example.com/a", published_at: be_present)
      expect(feed.reload).to have_attributes(last_fetched_at: be_present, error: nil, title: "Example")
    end

    it "keeps an existing title" do
      feed.update!(title: "My title")
      stub_request(:get, url).to_return(body: rss(%w[a]))

      described_class.call(feed)

      expect(feed.reload.title).to eq("My title")
    end

    it "keeps the previous title when fetching fails" do
      feed.update!(title: "Old title")
      stub_request(:get, url).to_return(status: 500)

      described_class.call(feed)

      expect(feed.reload.title).to eq("Old title")
    end

    it "stores entries from an Atom feed" do
      stub_request(:get, url).to_return(body: <<~XML)
        <?xml version="1.0" encoding="utf-8"?>
        <feed xmlns="http://www.w3.org/2005/Atom">
          <title>Example</title><id>urn:feed</id><updated>2026-10-01T00:00:00Z</updated>
          <author><name>Me</name></author>
          <entry>
            <title>Atom entry</title><id>urn:entry:1</id>
            <link href="https://example.com/atom/1"/>
            <updated>2026-10-01T00:00:00Z</updated><summary>Hello</summary>
          </entry>
        </feed>
      XML

      described_class.call(feed)

      expect(feed.rss_entries.sole).to have_attributes(
        guid: "urn:entry:1", url: "https://example.com/atom/1", summary: "Hello"
      )
    end

    it "only stores new entries" do
      feed.rss_entries.create!(guid: "a", title: "Existing")
      stub_request(:get, url).to_return(body: rss(%w[a b]))

      expect { described_class.call(feed) }.to change { feed.rss_entries.count }.by(1)
      expect(feed.rss_entries.find_by(guid: "a").title).to eq("Existing")
    end

    it "logs the fetch and the number of entries created" do
      stub_request(:get, url).to_return(body: rss(%w[a b]))
      allow(Rails.logger).to receive(:info)

      described_class.call(feed)

      expect(Rails.logger).to have_received(:info).with(/feed=#{feed.id} .*Fetching feed/)
      expect(Rails.logger).to have_received(:info).with(/feed=#{feed.id} .*created 2 entries/)
    end

    context "when the feed is inactive" do
      before { feed.update!(active: false) }

      it "does not fetch the feed" do
        stub = stub_request(:get, url)

        described_class.call(feed)

        expect(stub).not_to have_been_requested
        expect(feed.reload.last_fetched_at).to be_nil
      end
    end

    context "when fetching fails" do
      it "records the error and fetch time on a timeout" do
        stub_request(:get, url).to_timeout

        described_class.call(feed)

        expect(feed.reload).to have_attributes(last_fetched_at: be_present, error: /Timeout/)
      end

      it "records the error and fetch time on a non-success response" do
        stub_request(:get, url).to_return(status: 500)

        described_class.call(feed)

        expect(feed.reload).to have_attributes(last_fetched_at: be_present, error: "RuntimeError: HTTP 500")
      end

      it "records the error and fetch time when the body cannot be parsed" do
        stub_request(:get, url).to_return(body: "not a feed")

        described_class.call(feed)

        expect(feed.reload).to have_attributes(last_fetched_at: be_present, error: be_present)
        expect(feed.rss_entries).to be_empty
      end

      it "logs the error" do
        stub_request(:get, url).to_return(status: 500)
        allow(Rails.logger).to receive(:error)

        described_class.call(feed)

        expect(Rails.logger).to have_received(:error).with(/feed=#{feed.id} .*HTTP 500/)
      end
    end

    context "when storing entries fails" do
      it "records the error and fetch time, storing no entries" do
        stub_request(:get, url).to_return(body: rss(%w[a b]))
        allow(RssEntries::CreateService).to receive(:call).and_raise(ActiveRecord::RecordNotSaved, "boom")

        described_class.call(feed)

        expect(feed.reload).to have_attributes(last_fetched_at: be_present, error: /boom/)
        expect(feed.rss_entries).to be_empty
      end
    end

    it "clears a previous error after a successful fetch" do
      feed.update!(error: "old")
      stub_request(:get, url).to_return(body: rss(%w[a]))

      described_class.call(feed)

      expect(feed.reload.error).to be_nil
    end
  end
end
