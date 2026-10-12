# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Subscriptions", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:url) { "https://example.com/feed.xml" }

  describe "POST /api/subscriptions" do
    it "requires signing in" do
      post api_subscriptions_path, params: { url: url, title: "Feed" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(RssFeed.count).to eq(0)
    end

    context "when signed in" do
      before { sign_in user }

      it "subscribes to the feed and returns it" do
        post api_subscriptions_path, params: { url: url, title: "Feed" }, as: :json

        rss_feed = RssFeed.sole
        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq({ "id" => rss_feed.id, "title" => "Feed", "url" => url })
        expect(user.subscribed?(rss_feed)).to be(true)
      end

      it "returns the error when the feed cannot be added" do
        stub_request(:get, url).to_return(status: 500)

        post api_subscriptions_path, params: { url: url }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["error"]).to match(/HTTP 500/)
      end
    end
  end
end
