require "rails_helper"

RSpec.describe "Adding a feed", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
  end

  it "asks to sign in when signed out" do
    visit "/subscriptions/new"

    expect(page).to have_text("Sign in to add feeds.")
  end

  it "subscribes to a feed by URL and opens it" do
    sign_in user
    stub_request(:get, "https://example.com/feed.xml").to_return(body: <<~XML)
      <?xml version="1.0"?>
      <rss version="2.0"><channel><title>Example</title><link>https://example.com</link><description>Example</description></channel></rss>
    XML
    visit "/subscriptions/new"

    fill_in "URL", with: "https://example.com/feed.xml"
    click_button "Add feed"

    expect(page).to have_link("Example")
    expect(page).to have_current_path(%r{/feeds/\d+})
    expect(user.subscribed?(RssFeed.find_by!(url: "https://example.com/feed.xml"))).to be(true)
  end

  it "shows why the feed could not be added" do
    sign_in user
    stub_request(:get, "https://example.com/missing.xml").to_return(status: 404)
    visit "/subscriptions/new"

    fill_in "URL", with: "https://example.com/missing.xml"
    click_button "Add feed"

    expect(page).to have_css("[role=alert]", text: "HTTP 404")
  end
end
