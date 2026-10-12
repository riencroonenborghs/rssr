require "rails_helper"

RSpec.describe "Api::EntryBookmarks", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }
  let(:entry) { feed.rss_entries.create!(guid: "a") }

  it "requires a signed in user" do
    post api_entry_bookmark_path(entry)
    expect(response).to have_http_status(:unauthorized)

    delete api_entry_bookmark_path(entry)
    expect(response).to have_http_status(:unauthorized)
  end

  context "when signed in" do
    before do
      user.subscribe(feed)
      sign_in user
    end

    it "bookmarks an entry, once" do
      2.times { post api_entry_bookmark_path(entry) }

      expect(response).to have_http_status(:no_content)
      expect(user.bookmarks.where(rss_entry: entry).count).to eq(1)
    end

    it "removes a bookmark" do
      user.bookmark(entry)

      delete api_entry_bookmark_path(entry)

      expect(response).to have_http_status(:no_content)
      expect(user.bookmarked?(entry)).to be(false)
    end

    it "removes a bookmark of an entry whose feed the user unsubscribed from" do
      user.bookmark(entry)
      user.unsubscribe(feed)

      delete api_entry_bookmark_path(entry)

      expect(user.bookmarked?(entry)).to be(false)
    end

    it "returns not found for entries of feeds the user is not subscribed to" do
      other_entry = RssFeed.create!(url: "https://example.com/other.xml").rss_entries.create!(guid: "a")

      post api_entry_bookmark_path(other_entry)

      expect(response).to have_http_status(:not_found)
      expect(user.bookmarked?(other_entry)).to be(false)
    end
  end
end
