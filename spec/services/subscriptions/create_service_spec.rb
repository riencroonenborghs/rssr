require "rails_helper"

RSpec.describe Subscriptions::CreateService do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:url) { "https://example.com/feed.xml" }
  let(:rss) do
    <<~XML
      <?xml version="1.0"?>
      <rss version="2.0"><channel>
        <title> Example </title><link>https://example.com</link><description>Example</description>
      </channel></rss>
    XML
  end

  describe ".call" do
    context "with a title" do
      it "adds the feed with that title without fetching it, and subscribes the user" do
        stub = stub_request(:get, url)

        rss_feed = described_class.call(user, url: " #{url} ", title: " My feed ")

        expect(rss_feed).to have_attributes(persisted?: true, url: url, title: "My feed")
        expect(user.subscribed?(rss_feed)).to be(true)
        expect(stub).not_to have_been_requested
      end

      it "fetches the new feed's entries in the background" do
        expect do
          described_class.call(user, url: url, title: "My feed")
        end.to have_enqueued_job(RssFeeds::FetchJob).with(instance_of(RssFeed))
      end

      it "retitles an existing feed" do
        rss_feed = RssFeed.create!(url: url, title: "Old")

        described_class.call(user, url: url, title: "New")

        expect(rss_feed.reload.title).to eq("New")
      end
    end

    context "without a title" do
      it "uses the title read from the feed" do
        stub_request(:get, url).to_return(body: rss)

        rss_feed = described_class.call(user, url: url, title: " ")

        expect(rss_feed.title).to eq("Example")
        expect(user.subscribed?(rss_feed)).to be(true)
      end

      it "subscribes to an existing feed without fetching it or changing its title" do
        rss_feed = RssFeed.create!(url: url, title: "Existing")
        stub = stub_request(:get, url)

        expect do
          described_class.call(user, url: url)
        end.not_to have_enqueued_job(RssFeeds::FetchJob)

        expect(rss_feed.reload.title).to eq("Existing")
        expect(user.subscribed?(rss_feed)).to be(true)
        expect(stub).not_to have_been_requested
      end

      it "fails without adding the feed when it cannot be fetched" do
        stub_request(:get, url).to_return(status: 404)

        expect do
          described_class.call(user, url: url)
        end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: URL could not be downloaded (HTTP 404)")
        expect(RssFeed.count).to eq(0)
      end

      it "fails without adding the feed when it cannot be parsed" do
        stub_request(:get, url).to_return(body: "<html>not a feed</html>")

        expect { described_class.call(user, url: url) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(RssFeed.count).to eq(0)
      end
    end

    it "rejects a blank URL" do
      expect do
        described_class.call(user, url: " ", title: "Feed")
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: URL can't be blank")
    end

    it "rejects a URL that is not http or https" do
      expect do
        described_class.call(user, url: "ftp://example.com/feed.xml", title: "Feed")
      end.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: URL must start with http:// or https://")
      expect(RssFeed.count).to eq(0)
    end
  end
end
