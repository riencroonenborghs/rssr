# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Subscriptions", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password123") }
  let(:url) { "https://example.com/feed.xml" }

  describe "GET /api/subscriptions" do
    it "requires signing in" do
      get api_subscriptions_path, as: :json

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the user's subscriptions with their feeds, ordered by title" do
      sign_in user
      zebra = RssFeed.create!(url: "https://example.com/zebra.xml", title: "Zebra", error: "HTTP 500")
      apple = RssFeed.create!(url: "https://example.com/apple.xml", title: "apple")
      zebra_subscription = user.subscribe(zebra)
      apple_subscription = user.subscribe(apple)
      other_user.subscribe(RssFeed.create!(url: "https://example.com/other.xml"))

      get api_subscriptions_path, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([
        { "id" => apple_subscription.id, "feed" => { "id" => apple.id, "title" => "apple", "url" => apple.url, "error" => nil } },
        { "id" => zebra_subscription.id, "feed" => { "id" => zebra.id, "title" => "Zebra", "url" => zebra.url, "error" => "HTTP 500" } }
      ])
    end
  end

  describe "DELETE /api/subscriptions/:id" do
    let(:rss_feed) { RssFeed.create!(url: url) }

    it "requires signing in" do
      subscription = user.subscribe(rss_feed)

      delete api_subscription_path(subscription), as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(Subscription.exists?(subscription.id)).to be(true)
    end

    context "when signed in" do
      before { sign_in user }

      it "unsubscribes the user, keeping the feed" do
        subscription = user.subscribe(rss_feed)

        delete api_subscription_path(subscription), as: :json

        expect(response).to have_http_status(:no_content)
        expect(user.subscribed?(rss_feed)).to be(false)
        expect(RssFeed.exists?(rss_feed.id)).to be(true)
      end

      it "does not delete another user's subscription" do
        subscription = other_user.subscribe(rss_feed)

        delete api_subscription_path(subscription), as: :json

        expect(response).to have_http_status(:not_found)
        expect(Subscription.exists?(subscription.id)).to be(true)
      end
    end
  end

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
