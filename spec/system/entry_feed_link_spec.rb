require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Opening an entry's feed from a list", type: :system do
  let(:news) { RssFeed.create!(url: "https://example.com/news.xml", title: "News") }
  let(:tech) { RssFeed.create!(url: "https://example.com/tech.xml", title: "Tech") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
    news.rss_entries.create!(guid: "n", title: "News entry", published_at: 1.hour.ago)
    tech.rss_entries.create!(guid: "t", title: "Tech entry", published_at: 2.hours.ago)
    tech.rss_entries.create!(guid: "t2", title: "Older tech entry", published_at: 3.hours.ago)
  end

  it "opens the feed when its name is clicked" do
    visit "/"
    expect(page).to have_link("Tech entry")
    page.save_screenshot(Rails.root.join("tmp/screenshots/feed-link-dashboard.png")) if ENV["SCREENSHOTS"]

    within("main li", text: "Tech entry") { find("a[href='/feeds/#{tech.id}']").click }

    expect(page).to have_current_path("/feeds/#{tech.id}")
    expect(page).to have_css("header h2", text: "Tech")
    expect(page).to have_link("Older tech entry")
    expect(page).to have_no_link("News entry")
  end

  it "scrolls the feed list to the opened feed" do
    40.times { |i| RssFeed.create!(url: "https://example.com/#{i}.xml", title: format("Feed %02d", i)) }
    zebra = RssFeed.create!(url: "https://example.com/zebra.xml", title: "Zebra")
    zebra.rss_entries.create!(guid: "z", title: "Zebra entry", published_at: 1.minute.ago)
    visit "/"

    within("main li", text: "Zebra entry") { find("a[href='/feeds/#{zebra.id}']").click }

    expect(page).to have_current_path("/feeds/#{zebra.id}")
    link = find("main a[href='/feeds/#{zebra.id}']")
    main = find("main")
    expect(link.rect.y).to be >= main.rect.y
    expect(link.rect.y + link.rect.height).to be <= main.rect.y + main.rect.height
  end
end
