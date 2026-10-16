require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Theme", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
    feed.rss_entries.create!(guid: "a", title: "Read entry", summary: "<p>Summary with <a href='https://example.com'>a link</a></p>")
    feed.rss_entries.create!(guid: "b", title: "Unread entry")
    user.subscribe(feed)
  end

  def prefer_dark(dark)
    page.driver.browser.execute_cdp(
      "Emulation.setEmulatedMedia", features: [ { name: "prefers-color-scheme", value: dark ? "dark" : "light" } ]
    )
  end

  def dark?
    page.evaluate_script("document.documentElement.classList.contains('dark')")
  end

  def body_background
    page.evaluate_script("getComputedStyle(document.body).backgroundColor")
  end

  def background_of(element)
    page.evaluate_script("getComputedStyle(arguments[0]).backgroundColor", element)
  end

  def screenshot(name)
    page.save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png")) if ENV["SCREENSHOTS"]
  end

  it "switches to the dark theme and keeps it after a reload" do
    prefer_dark(false)
    sign_in user
    visit "/settings"
    expect(find_field("theme", with: "system")).to be_checked
    expect(dark?).to be(false)
    light_background = body_background

    choose "theme", option: "dark"
    expect(page).to have_css("html.dark")
    expect(body_background).not_to eq(light_background)
    screenshot("theme-1-settings-dark")

    visit "/"
    click_link "Read entry"
    expect(page).to have_text("Summary with")
    expect(dark?).to be(true)
    screenshot("theme-2-entry-dark")

    refresh
    expect(dark?).to be(true)

    visit "/settings"
    choose "theme", option: "light"
    expect(page).to have_no_css("html.dark")
  end

  it "follows the device preference with the system theme" do
    prefer_dark(true)
    visit "/"
    expect(page).to have_css("html.dark")

    prefer_dark(false)
    expect(page).to have_no_css("html.dark")
  end

  it "uses dark green for the navigation in the dark theme" do
    dark_green = "rgb(29, 68, 25)"
    prefer_dark(true)
    visit "/"
    expect(page).to have_css("html.dark")
    expect(background_of(find("nav[aria-label='Main']"))).to eq(dark_green)

    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 1, mobile: true
    )
    expect(background_of(find("header", text: "Dashboard"))).to eq(dark_green)
    screenshot("theme-4-phone-dark")

    click_button "Open menu"
    expect(background_of(find("dialog[open]"))).to eq(dark_green)
    screenshot("theme-5-phone-menu-dark")
  end

  it "shows the sign in modal in the dark theme" do
    prefer_dark(true)
    visit "/"
    click_button "Sign in"
    expect(page).to have_field("Email")
    screenshot("theme-3-sign-in-dark")
  end
end
