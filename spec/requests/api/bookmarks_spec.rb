require "rails_helper"

RSpec.describe "Api::Bookmarks", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }

  def entry(title)
    feed.rss_entries.create!(guid: SecureRandom.uuid, title: title)
  end

  describe "GET /api/bookmarks" do
    it "requires a signed in user" do
      get api_bookmarks_path

      expect(response).to have_http_status(:unauthorized)
    end

    context "when signed in" do
      before { sign_in user }

      it "lists bookmarked entries of any feed, most recently bookmarked first, ignoring filters" do
        first = entry("First bookmarked, apple")
        second = entry("Second bookmarked")
        entry("Not bookmarked")
        user.bookmark(first)
        user.bookmark(second)
        user.mark_read(first)
        user.filters.create!(kind: :keyword, value: "apple")
        User.create!(email: "other@example.com", password: "password123").bookmark(entry("Other user's bookmark"))

        get api_bookmarks_path

        expect(response.parsed_body["entries"].map { |e| e.slice("title", "read", "bookmarked") }).to eq([
          { "title" => "Second bookmarked", "read" => false, "bookmarked" => true },
          { "title" => "First bookmarked, apple", "read" => true, "bookmarked" => true }
        ])
        expect(response.parsed_body["next_page"]).to be_nil
      end

      it "returns a page at a time" do
        stub_const("Api::BaseController::PER_PAGE", 1)
        2.times { |i| user.bookmark(entry("Entry #{i}")) }

        get api_bookmarks_path

        expect(response.parsed_body["entries"].size).to eq(1)
        expect(response.parsed_body["next_page"]).to eq(2)
      end
    end
  end

  it "lets a user open a bookmarked entry of a feed they are not subscribed to" do
    bookmarked = entry("Bookmarked")
    user.bookmark(bookmarked)
    sign_in user

    get api_entry_path(bookmarked)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("title" => "Bookmarked", "bookmarked" => true)
  end
end
