# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Entries", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }
  let(:other_feed) { RssFeed.create!(url: "https://example.com/other.xml") }

  before { user.subscribe(feed) }

  describe "GET /api/feeds/:feed_id/entries" do
    context "when signed out" do
      it "lists any feed's entries newest first, unread and not bookmarked" do
        older = other_feed.rss_entries.create!(guid: "older", title: "Older", published_at: Time.utc(2026, 10, 1))
        newer = other_feed.rss_entries.create!(guid: "newer", title: "Apple", published_at: Time.utc(2026, 10, 2))
        user.subscribe(other_feed)
        user.mark_read(older)
        user.bookmark(newer)
        user.filters.create!(kind: :keyword, value: "apple")

        get api_feed_entries_path(other_feed)

        expect(response.parsed_body["entries"]).to eq([
                                                        { "id" => newer.id, "title" => "Apple", "published_at" => "2026-10-02T00:00:00.000Z", "image_url" => nil, "read" => false, "bookmarked" => false, "feed" => { "id" => other_feed.id, "title" => other_feed.url } },
          { "id" => older.id, "title" => "Older", "published_at" => "2026-10-01T00:00:00.000Z", "image_url" => nil, "read" => false, "bookmarked" => false, "feed" => { "id" => other_feed.id, "title" => other_feed.url } }
                                                      ])
      end

      it "returns the entries a page at a time" do
        stub_const("Api::BaseController::PER_PAGE", 2)
        3.times { |i| feed.rss_entries.create!(guid: i.to_s, title: "Entry #{i}", published_at: i.days.ago) }
        other_feed.rss_entries.create!(guid: "other")

        get api_feed_entries_path(feed)
        expect(response.parsed_body["entries"].pluck("title")).to eq([ "Entry 0", "Entry 1" ])
        expect(response.parsed_body["next_page"]).to eq(2)

        get api_feed_entries_path(feed, page: 2)
        expect(response.parsed_body["entries"].pluck("title")).to eq([ "Entry 2" ])
        expect(response.parsed_body["next_page"]).to be_nil
      end

      it "returns not found for unknown feeds" do
        get api_feed_entries_path(feed_id: 0)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when signed in" do
      before { sign_in user }

      it "lists the feed's entries newest first with read and bookmarked state" do
        older = feed.rss_entries.create!(guid: "older", title: "Older", published_at: Time.utc(2026, 10, 1))
        newer = feed.rss_entries.create!(guid: "newer", title: "Newer", published_at: Time.utc(2026, 10, 2))
        user.mark_read(older)
        user.bookmark(newer)

        get api_feed_entries_path(feed)

        expect(response.parsed_body["entries"]).to eq([
                                                        { "id" => newer.id, "title" => "Newer", "published_at" => "2026-10-02T00:00:00.000Z", "image_url" => nil, "read" => false, "bookmarked" => true, "feed" => { "id" => feed.id, "title" => "Feed" } },
          { "id" => older.id, "title" => "Older", "published_at" => "2026-10-01T00:00:00.000Z", "image_url" => nil, "read" => true, "bookmarked" => false, "feed" => { "id" => feed.id, "title" => "Feed" } }
                                                      ])
      end

      it "falls back to when the entry was stored for the date" do
        entry = feed.rss_entries.create!(guid: "a")

        get api_feed_entries_path(feed)

        expect(Time.zone.parse(response.parsed_body["entries"].sole["published_at"])).to be_within(1.second).of(entry.created_at)
      end

      it "hides entries matching the user's filters" do
        feed.rss_entries.create!(guid: "a", title: "Apple news")
        feed.rss_entries.create!(guid: "b", title: "Banana news")
        user.filters.create!(kind: :keyword, value: "apple")

        get api_feed_entries_path(feed)

        expect(response.parsed_body["entries"].pluck("title")).to eq([ "Banana news" ])
      end

      it "returns not found for feeds the user is not subscribed to" do
        get api_feed_entries_path(other_feed)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /api/entries/:id when signed out" do
    it "returns any entry, unread and not bookmarked" do
      entry = other_feed.rss_entries.create!(guid: "a", title: "Title")
      user.subscribe(other_feed)
      user.mark_read(entry)
      user.bookmark(entry)

      get api_entry_path(entry)

      expect(response.parsed_body).to include("id" => entry.id, "title" => "Title", "read" => false, "bookmarked" => false)
    end
  end

  describe "GET /api/entries/:id" do
    before { sign_in user }

    it "returns the entry with sanitized summary HTML" do
      entry = feed.rss_entries.create!(
        guid: "a", title: "Title", url: "https://example.com/a", published_at: Time.utc(2026, 10, 1),
        summary: %(<p onclick="evil()">Hello <a href="https://example.com">link</a></p><script>alert(1)</script>)
      )
      user.bookmark(entry)

      get api_entry_path(entry)

      expect(response.parsed_body).to eq(
        "id" => entry.id,
        "title" => "Title",
        "url" => "https://example.com/a",
        "summary_html" => %(<p>Hello <a href="https://example.com">link</a></p>alert(1)),
        "published_at" => "2026-10-01T00:00:00.000Z", "image_url" => nil,
        "read" => false,
        "bookmarked" => true,
        "feed" => { "id" => feed.id, "title" => "Feed" }
      )
    end

    it "does not mark the entry as read" do
      entry = feed.rss_entries.create!(guid: "a")

      get api_entry_path(entry)

      expect(user.read?(entry)).to be(false)
    end

    it "returns not found for entries of feeds the user is not subscribed to" do
      get api_entry_path(other_feed.rss_entries.create!(guid: "a"))

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/entries/:entry_id/read" do
    it "requires a signed in user" do
      post api_entry_read_path(feed.rss_entries.create!(guid: "a"))

      expect(response).to have_http_status(:unauthorized)
    end

    context "when signed in" do
      before { sign_in user }

      it "marks the entry as read, once" do
        entry = feed.rss_entries.create!(guid: "a")

        2.times { post api_entry_read_path(entry) }

        expect(response).to have_http_status(:no_content)
        expect(user.rss_entry_reads.where(rss_entry: entry).count).to eq(1)
      end

      it "returns not found for entries of feeds the user is not subscribed to" do
        post api_entry_read_path(other_feed.rss_entries.create!(guid: "a"))

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
