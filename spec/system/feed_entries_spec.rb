require "rails_helper"

RSpec.describe "A feed's entries", type: :system do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
    stub_const("Api::BaseController::PER_PAGE", 2)
    3.times { |i| feed.rss_entries.create!(guid: i.to_s, title: "Entry #{i}", published_at: i.hours.ago) }
  end

  it "loads more entries a page at a time" do
    visit "/feeds/#{feed.id}"
    expect(page).to have_link("Entry 1")
    expect(page).to have_no_link("Entry 2")

    click_button "Load more"

    expect(page).to have_link("Entry 2")
    expect(page).to have_no_button("Load more")
  end
end
