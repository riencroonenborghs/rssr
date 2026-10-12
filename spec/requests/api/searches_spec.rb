require "rails_helper"

RSpec.describe "Api::Searches", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }
  let(:other_feed) { RssFeed.create!(url: "https://example.com/other.xml", title: "Other") }

  def entry(feed, title, published_at: Time.current, summary: nil)
    feed.rss_entries.create!(guid: SecureRandom.uuid, title: title, summary: summary, published_at: published_at)
  end

  it "searches all feeds newest first when signed out" do
    entry(feed, "Older apple", published_at: 2.days.ago)
    entry(other_feed, "Newer", summary: "About an apple", published_at: 1.day.ago)
    entry(feed, "Banana")

    get api_search_path(q: "apple")

    expect(response.parsed_body["entries"].pluck("title")).to eq([ "Newer", "Older apple" ])
    expect(response.parsed_body["next_page"]).to be_nil
  end

  it "searches only subscribed feeds, after filters, when signed in" do
    entry(feed, "Apple news")
    entry(feed, "Apple filtered out, sponsored")
    entry(other_feed, "Apple elsewhere")
    user.subscribe(feed)
    user.filters.create!(kind: :keyword, value: "sponsored")
    sign_in user

    get api_search_path(q: "apple")

    expect(response.parsed_body["entries"].pluck("title")).to eq([ "Apple news" ])
  end

  it "returns no entries without a query" do
    entry(feed, "Anything")

    get api_search_path

    expect(response.parsed_body).to eq("entries" => [], "next_page" => nil)
  end

  it "returns a page at a time" do
    stub_const("Api::BaseController::PER_PAGE", 1)
    2.times { |i| entry(feed, "Apple #{i}") }

    get api_search_path(q: "apple", page: 1)

    expect(response.parsed_body["entries"].size).to eq(1)
    expect(response.parsed_body["next_page"]).to eq(2)
  end
end
