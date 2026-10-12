require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Resizing the list column", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
    RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed").rss_entries.create!(guid: "a", title: "An entry")
  end

  def list_width
    find("main").rect.width.round
  end

  def handle
    find("[role='separator'][aria-label='Resize list']")
  end

  def drag_handle(by)
    page.driver.browser.action.click_and_hold(handle.native).move_by(by, 0).release.perform
  end

  it "resizes by dragging, keeps the width after a reload, and resets on double click" do
    visit "/"
    expect(page).to have_link("An entry")
    expect(list_width).to eq(384)

    drag_handle(150)
    expect(list_width).to be_within(4).of(534)
    page.save_screenshot(Rails.root.join("tmp/screenshots/resized-list.png")) if ENV["SCREENSHOTS"]

    refresh
    expect(page).to have_link("An entry")
    expect(list_width).to be_within(4).of(534)

    handle.double_click
    expect(list_width).to eq(384)
  end

  it "stays within its limits" do
    visit "/"
    expect(page).to have_link("An entry")

    drag_handle(-400)
    expect(list_width).to eq(256)

    drag_handle(900)
    expect(list_width).to eq(640)
  end

  it "resizes with the arrow keys" do
    visit "/"
    expect(page).to have_link("An entry")

    handle.send_keys(:right)
    expect(list_width).to eq(400)
    handle.send_keys(:left, :left)
    expect(list_width).to eq(368)
  end
end
