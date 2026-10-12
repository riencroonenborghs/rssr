require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Settings", type: :system do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
    # A real image, served by the app under test.
    server = Capybara.current_session.server
    feed.rss_entries.create!(guid: "a", title: "With an image", image_url: "http://#{server.host}:#{server.port}/icon.png")
    feed.rss_entries.create!(guid: "b", title: "Without an image")
  end

  def screenshot(name)
    page.save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png")) if ENV["SCREENSHOTS"]
  end

  def row_height(title)
    find("main a", text: title).rect.height
  end

  it "switches entries between the regular and compact layouts, remembering the choice" do
    visit "/"
    expect(page).to have_css("main img[src$='/icon.png']")
    regular_height = row_height("Without an image")
    screenshot("settings-1-regular")

    click_link "Settings"
    expect(page).to have_checked_field("Regular")
    choose "Compact"
    screenshot("settings-2-page")

    click_link "Dashboard"
    expect(page).to have_link("With an image")
    expect(page).to have_no_css("main img")
    expect(row_height("Without an image")).to be < regular_height
    screenshot("settings-3-compact")

    refresh
    expect(page).to have_link("With an image")
    expect(page).to have_no_css("main img")

    visit "/settings"
    expect(page).to have_checked_field("Compact")
  end
end
