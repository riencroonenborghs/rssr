require "rails_helper"

RSpec.describe "Api::Entries (all feeds)", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }
  let(:other_feed) { RssFeed.create!(url: "https://example.com/other.xml", title: "Other") }

  def entry(feed, title, published_at)
    feed.rss_entries.create!(guid: SecureRandom.uuid, title: title, published_at: published_at)
  end

  describe "GET /api/entries" do
    it "lists the entries of all feeds newest first when signed out" do
      entry(feed, "Older", 2.days.ago)
      entry(other_feed, "Newer", 1.day.ago)

      get api_entries_path

      expect(response.parsed_body["entries"].map { |e| [ e["title"], e["feed"]["title"] ] })
        .to eq([ [ "Newer", "Other" ], [ "Older", "Feed" ] ])
      expect(response.parsed_body["next_page"]).to be_nil
    end

    it "lists only the subscribed feeds' entries after filters, with read and bookmarked state, when signed in" do
      read = entry(feed, "Read", 3.days.ago)
      bookmarked = entry(feed, "Bookmarked", 2.days.ago)
      entry(feed, "Apple news", 1.day.ago)
      entry(other_feed, "Not subscribed", 1.hour.ago)
      user.subscribe(feed)
      user.mark_read(read)
      user.bookmark(bookmarked)
      user.filters.create!(kind: :keyword, value: "apple")
      sign_in user

      get api_entries_path

      expect(response.parsed_body["entries"].map { |e| e.slice("title", "read", "bookmarked") }).to eq([
        { "title" => "Bookmarked", "read" => false, "bookmarked" => true },
        { "title" => "Read", "read" => true, "bookmarked" => false }
      ])
    end

    it "returns a page at a time" do
      stub_const("Api::BaseController::PER_PAGE", 2)
      titles = Array.new(5) { |i| entry(feed, "Entry #{i}", i.days.ago).title }

      get api_entries_path
      expect(response.parsed_body["entries"].pluck("title")).to eq(titles[0, 2])
      expect(response.parsed_body["next_page"]).to eq(2)

      get api_entries_path(page: 3)
      expect(response.parsed_body["entries"].pluck("title")).to eq(titles[4, 1])
      expect(response.parsed_body["next_page"]).to be_nil
    end
  end
end
