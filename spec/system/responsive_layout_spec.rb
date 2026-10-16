# frozen_string_literal: true

require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots of each step to tmp/screenshots.
RSpec.describe "Responsive layout", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Example feed") }
  let!(:entry) do
    feed.rss_entries.create!(
      guid: "a", title: "A fairly long entry title that needs to wrap on a phone screen",
      summary: "<p>The entry's summary.</p>", url: "https://example.com/a", published_at: Time.utc(2026, 10, 1)
    )
  end

  before do
    driven_by :selenium, using: :headless_chrome
    user.subscribe(feed)
    feed.rss_entries.create!(guid: "b", title: "Another entry", published_at: Time.utc(2026, 9, 30))
    sign_in user
  end

  # Headless Chrome has a minimum window size, so emulate the viewport instead of resizing.
  def use_viewport(width, height, mobile:)
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: width, height: height, deviceScaleFactor: 1, mobile: mobile
    )
  end

  def screenshot(name)
    page.save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png")) if ENV["SCREENSHOTS"]
  end

  context "on a phone" do
    before { use_viewport(390, 844, mobile: true) }

    it "has a top bar with a menu and shows one column at a time" do
      visit "/"
      header = find("header", text: "Dashboard")
      expect(header.rect.y).to eq(0)
      expect(page).to have_no_link("Feeds")
      screenshot("phone-0-dashboard")

      click_button "Open menu"
      within("dialog[open]") do
        expect(page).to have_link("Bookmarks")
        expect(page).to have_link("Settings")
        expect(find("nav").rect.width).to eq(390)
        expect(page).to have_button("Sign out")
        expect(page).to have_link("Jobs", href: "/solid_queue/")
        screenshot("phone-1-menu")
        click_link "Feeds"
      end
      expect(page).to have_no_css("dialog[open]")
      expect(page).to have_css("header", text: "Feeds")
      expect(page).to have_link("Example feed")
      expect(page).to have_no_text("Select a feed")
      screenshot("phone-2-feeds")

      click_link "Example feed"
      expect(page).to have_link(entry.title)
      expect(page).to have_no_css("main", visible: :visible)
      screenshot("phone-3-entries")

      entry_window = window_opened_by { click_link entry.title }
      within_window(entry_window) do
        expect(page).to have_css("h1", text: entry.title)
        expect(page).to have_text("The entry's summary.")
      end
      entry_window.close
      # Reading the entry in its tab shows it as read here.
      expect(page).to have_css("p.text-gray-400", text: entry.title)

      click_link "Back to feeds"
      expect(page).to have_link("Example feed")
      expect(page).to have_no_css("section", visible: :visible)

      expect(page.evaluate_script("document.documentElement.scrollWidth")).to be <= 390
    end

    it "closes the menu without navigating" do
      visit "/feeds"
      click_button "Open menu"
      click_button "Close menu"

      expect(page).to have_no_css("dialog[open]")
      expect(page).to have_current_path("/feeds")
    end

    it "shows feeds and entries when signed out, without marking entries read" do
      sign_out user
      unsubscribed = RssFeed.create!(url: "https://example.com/other.xml", title: "Unsubscribed feed")
      unsubscribed.rss_entries.create!(guid: "c", title: "Entry of an unsubscribed feed")

      visit "/feeds"
      expect(page).to have_link("Unsubscribed feed")
      click_link "Example feed"
      entry_window = window_opened_by { click_link entry.title }
      within_window(entry_window) { expect(page).to have_text("The entry's summary.") }
      entry_window.close

      expect(page).to have_css("p.font-medium", text: entry.title)
      expect(user.read?(entry)).to be(false)
    end

    it "signs in through the modal" do
      sign_out user
      visit "/feeds"
      expect(page).to have_link("Example feed")

      click_button "Open menu"
      within("dialog[open]") { expect(page).to have_no_link("Jobs") }
      within("dialog[open]") { click_button "Sign in" }
      within("dialog[open]") do
        expect(find("form").rect.width).to be < 390
        screenshot("phone-5-sign-in")
        fill_in "Email", with: user.email
        fill_in "Password", with: "password123"
        click_button "Sign in"
      end

      expect(page).to have_link("Example feed")
      click_button "Open menu"
      within("dialog[open]") { expect(page).to have_button("Sign out") }
    end
  end

  context "on a desktop" do
    before { use_viewport(1280, 800, mobile: false) }

    it "shows the navigation, feeds and entries side by side" do
      visit "/feeds/#{feed.id}"

      expect(page).to have_link("Example feed")
      expect(page).to have_link(entry.title)
      expect(page).to have_no_link("Back to feeds")
      expect(find("nav").rect.width).to eq(64)
      expect(page).to have_link("Jobs", href: "/solid_queue/")
      screenshot("desktop-entries")

      feed_link = find("main a", text: "Example feed")
      expect(feed_link).to have_text("2")

      entry_window = window_opened_by { click_link entry.title }
      within_window(entry_window) do
        expect(page).to have_css("h1", text: entry.title)
        screenshot("desktop-entry")
      end

      # The list stays in this tab, and reading the entry in the new tab updates it.
      expect(page).to have_link(entry.title)
      expect(page).to have_css("p.text-gray-400", text: entry.title)
      expect(feed_link).to have_text("1")
      entry_window.close
    end
  end
end
