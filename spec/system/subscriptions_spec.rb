require "rails_helper"

RSpec.describe "Managing subscriptions", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
  end

  it "asks to sign in when signed out" do
    visit "/subscriptions"

    expect(page).to have_text("Sign in to manage your subscriptions.")
  end

  it "lists subscriptions and unsubscribes from a feed" do
    example = RssFeed.create!(url: "https://example.com/feed.xml", title: "Example")
    other = RssFeed.create!(url: "https://example.com/other.xml", title: "Other")
    user.subscribe(example)
    user.subscribe(other)
    sign_in user
    visit "/"

    click_link "Subscriptions"
    expect(page).to have_current_path("/subscriptions")
    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "Example")
    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "Other")

    click_button "Unsubscribe from Example"

    expect(page).to have_no_css("ul[aria-label=Subscriptions] li", text: "Example")
    expect(user.rss_feeds).to eq([ other ])
  end

  it "links to adding a feed" do
    sign_in user
    visit "/subscriptions"

    expect(page).to have_text("You have no subscriptions yet.")
    within("main") { click_link "Add a feed" }

    expect(page).to have_current_path("/subscriptions/new")
  end
end
