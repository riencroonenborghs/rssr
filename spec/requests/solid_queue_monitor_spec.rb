# frozen_string_literal: true

require "rails_helper"

# The test environment has no queue database, so this only checks that signing in is required.
RSpec.describe "Solid Queue monitor", type: :request do
  it "redirects to sign in when signed out" do
    get "/solid_queue"

    expect(response).to redirect_to("/users/sign_in")
  end
end
