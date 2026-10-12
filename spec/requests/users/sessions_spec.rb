require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let!(:user) { User.create!(email: "user@example.com", password: "password123") }

  def sign_in_with_json(password)
    post user_session_path, params: { user: { email: user.email, password: password } }, as: :json
  end

  describe "POST /users/sign_in as JSON" do
    it "signs the user in" do
      sign_in_with_json("password123")

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to include("id" => user.id, "email" => user.email)
      expect(response.parsed_body.keys).not_to include("encrypted_password")

      get root_path
      expect(Nokogiri::HTML(response.body).at_css("#root")["data-signed-in"]).to eq("true")
    end

    it "returns the error for invalid credentials" do
      sign_in_with_json("wrong")

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to eq("error" => "Invalid email or password.")
    end
  end

  it "still signs in through the HTML form" do
    post user_session_path, params: { user: { email: user.email, password: "password123" } }

    expect(response).to redirect_to(root_path)
  end
end
