require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Toggling bookmarks", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Feed") }
  let!(:entry) { feed.rss_entries.create!(guid: "a", title: "An entry", summary: "<p>Summary</p>") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
  end

  context "when signed in" do
    before do
      user.subscribe(feed)
      sign_in user
    end

    it "toggles from the list and the details, keeping both tabs in sync" do
      visit "/"
      entry_window = window_opened_by { click_link "An entry" }
      within_window(entry_window) { expect(page).to have_text("Summary") }

      within("main") { click_button "Bookmark" }
      expect(page).to have_button("Remove bookmark")
      expect(user.bookmarked?(entry)).to be(true)
      within_window(entry_window) do
        within("article") { expect(page).to have_button("Remove bookmark") }
        page.save_screenshot(Rails.root.join("tmp/screenshots/desktop-bookmarked.png")) if ENV["SCREENSHOTS"]

        within("article") { click_button "Remove bookmark" }
        within("article") { expect(page).to have_button("Bookmark") }
      end
      expect(user.bookmarked?(entry)).to be(false)
      within("main") { expect(page).to have_button("Bookmark") }
    end

    it "keeps an unbookmarked entry on the bookmarks page until it is reloaded" do
      user.bookmark(entry)
      visit "/bookmarks"

      click_button "Remove bookmark"
      expect(page).to have_button("Bookmark")
      expect(page).to have_link("An entry")

      visit "/bookmarks"
      expect(page).to have_text("You have no bookmarks yet.")
    end
  end

  it "shows no bookmark buttons when signed out" do
    visit "/"
    expect(page).to have_no_button("Bookmark")

    entry_window = window_opened_by { click_link "An entry" }
    within_window(entry_window) do
      expect(page).to have_text("Summary")
      expect(page).to have_no_button("Bookmark")
    end
  end
end
