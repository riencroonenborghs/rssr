require "rails_helper"

RSpec.describe "Home", type: :request do
  def root_element
    Nokogiri::HTML(response.body).at_css("#root")
  end

  %w[/ /feeds /bookmarks /search /subscriptions /subscriptions/new /filters /settings].each do |path|
    it "serves the React app at #{path}" do
      get path

      expect(response).to have_http_status(:ok)
      expect(root_element).to be_present
      expect(response.body).to match(%r{<script[^>]+src="/assets/application-[^"]+\.js"})
    end
  end

  it "tells the app the user is signed out, with the sign in path" do
    get root_path

    expect(root_element["data-signed-in"]).to eq("false")
    expect(root_element["data-sign-in-path"]).to eq(new_user_session_path)
  end

  it "tells the app the user is signed in, with the sign out path" do
    sign_in User.create!(email: "user@example.com", password: "password123")

    get root_path

    expect(root_element["data-signed-in"]).to eq("true")
    expect(root_element["data-sign-out-path"]).to eq(destroy_user_session_path)
  end

  it "signs out via the method override the sign out button submits" do
    sign_in User.create!(email: "user@example.com", password: "password123")

    post destroy_user_session_path, params: { _method: "delete" }
    get root_path

    expect(root_element["data-signed-in"]).to eq("false")
  end
end
