require "rails_helper"
require_relative "../../support/anthropic_stubs"

RSpec.describe "Api::Summaries", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Example") }

  around do |example|
    previous = ENV["ANTHROPIC_API"]
    ENV["ANTHROPIC_API"] = "test-key"
    example.run
  ensure
    ENV["ANTHROPIC_API"] = previous
  end

  it "requires signing in" do
    post api_summary_path, params: { keywords: "electric", period: "24h" }, as: :json

    expect(response).to have_http_status(:unauthorized)
  end

  context "when signed in" do
    before { sign_in user }

    it "summarizes the subscribed entries matching the keywords" do
      user.subscribe(feed)
      entry = feed.rss_entries.create!(guid: "1", title: "Electric cars", url: "https://example.com/1", published_at: 1.hour.ago)
      unsubscribed = RssFeed.create!(url: "https://example.com/other.xml")
      unsubscribed.rss_entries.create!(guid: "2", title: "Electric bikes", published_at: 1.hour.ago)
      stub_claude_summary("Overview [1]")

      post api_summary_path, params: { keywords: "electric", period: "24h" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({
        "summary" => "Overview [1]",
        "total" => 1,
        "entries" => [ { "id" => entry.id, "title" => "Electric cars", "url" => "https://example.com/1",
                         "published_at" => entry.published_at.as_json, "feed" => { "id" => feed.id, "title" => "Example" } } ]
      })
    end

    it "returns no summary when nothing matches" do
      post api_summary_path, params: { keywords: "electric", period: "week" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ "summary" => nil, "total" => 0, "entries" => [] })
    end

    it "returns the error when the summary cannot be created" do
      post api_summary_path, params: { keywords: "electric", period: "year" }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to match(/period/)
    end
  end
end
