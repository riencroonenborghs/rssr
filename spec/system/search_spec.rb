require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Search", type: :system do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
    feed.rss_entries.create!(guid: "a", title: "Apple releases a phone")
    feed.rss_entries.create!(guid: "b", title: "Fruit", summary: "<p>Apples and pears</p>")
    feed.rss_entries.create!(guid: "c", title: "Bananas")
  end

  it "searches titles and summaries as you type, keeping the query in the URL" do
    visit "/search"
    expect(page).to have_text("Type to search entry titles and summaries.")

    fill_in "Search titles and summaries", with: "appl"
    expect(page).to have_link("Apple releases a phone")
    expect(page).to have_link("Fruit")
    expect(page).to have_no_link("Bananas")
    expect(page).to have_current_path("/search?q=appl")
    page.save_screenshot(Rails.root.join("tmp/screenshots/search.png")) if ENV["SCREENSHOTS"]

    refresh
    expect(page).to have_field("Search titles and summaries", with: "appl")
    expect(page).to have_link("Fruit")

    fill_in "Search titles and summaries", with: "kiwi"
    expect(page).to have_text("No entries match your search.")
    expect(page).to have_no_link("Fruit")
  end
end
