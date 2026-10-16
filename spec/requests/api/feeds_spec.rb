# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Feeds", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  describe "GET /api/feeds" do
    context "when signed out" do
      it "lists all feeds by title, counting all their entries as unread" do
        zebra = RssFeed.create!(url: "https://example.com/z.xml", title: "Zebra")
        apple = RssFeed.create!(url: "https://example.com/a.xml", title: "Apple")
        2.times { |i| zebra.rss_entries.create!(guid: i.to_s) }
        user.subscribe(zebra)
        user.mark_read(zebra.rss_entries.first)
        user.filters.create!(kind: :keyword, value: "anything")

        get api_feeds_path

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq([
                                             { "id" => apple.id, "title" => "Apple", "url" => apple.url, "unread_count" => 0 },
          { "id" => zebra.id, "title" => "Zebra", "url" => zebra.url, "unread_count" => 2 }
                                           ])
      end
    end

    context "when signed in" do
      before { sign_in user }

      it "lists subscribed feeds by title with their unread counts" do
        zebra = RssFeed.create!(url: "https://example.com/z.xml", title: "Zebra")
        apple = RssFeed.create!(url: "https://example.com/a.xml", title: "apple")
        untitled = RssFeed.create!(url: "https://example.com/m.xml")
        RssFeed.create!(url: "https://example.com/not-subscribed.xml", title: "Other")
        [ zebra, apple, untitled ].each { |feed| user.subscribe(feed) }
        read, _unread = Array.new(2) { |i| zebra.rss_entries.create!(guid: i.to_s) }
        user.mark_read(read)
        apple.rss_entries.create!(guid: "a")

        get api_feeds_path

        expect(response.parsed_body).to eq([
                                             { "id" => apple.id, "title" => "apple", "url" => apple.url, "unread_count" => 1 },
          { "id" => untitled.id, "title" => untitled.url, "url" => untitled.url, "unread_count" => 0 },
          { "id" => zebra.id, "title" => "Zebra", "url" => zebra.url, "unread_count" => 1 }
                                           ])
      end

      it "does not count entries hidden by the user's filters" do
        feed = RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed")
        user.subscribe(feed)
        feed.rss_entries.create!(guid: "a", title: "Apple news")
        feed.rss_entries.create!(guid: "b", title: "Banana news")
        user.filters.create!(kind: :keyword, value: "apple")

        get api_feeds_path

        expect(response.parsed_body.sole["unread_count"]).to eq(1)
      end

      it "does not count entries read by other users as read" do
        feed = RssFeed.create!(url: "https://example.com/feed.xml")
        user.subscribe(feed)
        entry = feed.rss_entries.create!(guid: "a")
        User.create!(email: "other@example.com", password: "password123").mark_read(entry)

        get api_feeds_path

        expect(response.parsed_body.sole["unread_count"]).to eq(1)
      end
    end
  end
end
