# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::Filters", type: :request do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password123") }

  it "requires signing in" do
    get api_filters_path, as: :json
    expect(response).to have_http_status(:unauthorized)

    post api_filters_path, params: { kind: "keyword", value: "ads" }, as: :json
    expect(response).to have_http_status(:unauthorized)
    expect(Filter.count).to eq(0)
  end

  context "when signed in" do
    before { sign_in user }

    describe "GET /api/filters" do
      it "returns the user's filters ordered by kind and value" do
        regexp = user.filters.create!(kind: "regexp", value: "^Ad:")
        sponsored = user.filters.create!(kind: "keyword", value: "sponsored")
        ads = user.filters.create!(kind: "keyword", value: "ads")
        other_user.filters.create!(kind: "keyword", value: "other")

        get api_filters_path, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq([
          { "id" => ads.id, "kind" => "keyword", "value" => "ads" },
          { "id" => sponsored.id, "kind" => "keyword", "value" => "sponsored" },
          { "id" => regexp.id, "kind" => "regexp", "value" => "^Ad:" }
        ])
      end
    end

    describe "POST /api/filters" do
      it "creates the filter and returns it" do
        post api_filters_path, params: { kind: "regexp", value: " \\bgiveaway\\b " }, as: :json

        filter = user.filters.sole
        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq({ "id" => filter.id, "kind" => "regexp", "value" => "\\bgiveaway\\b" })
      end

      it "returns the error when the filter is invalid" do
        post api_filters_path, params: { kind: "regexp", value: "(" }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body["error"]).to match(/not a valid regular expression/)
        expect(Filter.count).to eq(0)
      end

      it "returns the error when the kind is unknown" do
        post api_filters_path, params: { kind: "other", value: "ads" }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(Filter.count).to eq(0)
      end
    end

    describe "DELETE /api/filters/:id" do
      it "deletes the filter" do
        filter = user.filters.create!(kind: "keyword", value: "ads")

        delete api_filter_path(filter), as: :json

        expect(response).to have_http_status(:no_content)
        expect(Filter.exists?(filter.id)).to be(false)
      end

      it "does not delete another user's filter" do
        filter = other_user.filters.create!(kind: "keyword", value: "ads")

        delete api_filter_path(filter), as: :json

        expect(response).to have_http_status(:not_found)
        expect(Filter.exists?(filter.id)).to be(true)
      end
    end
  end
end
