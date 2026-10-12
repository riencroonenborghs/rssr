require "rails_helper"

# Set SCREENSHOTS=1 to save screenshots to tmp/screenshots.
RSpec.describe "Dashboard and bookmarks", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:news) { RssFeed.create!(url: "https://example.com/news.xml", title: "News") }
  let(:tech) { RssFeed.create!(url: "https://example.com/tech.xml", title: "Tech") }
  let!(:news_entry) { news.rss_entries.create!(guid: "n", title: "News entry", summary: "<p>News summary</p>", published_at: 1.hour.ago) }
  let!(:tech_entry) { tech.rss_entries.create!(guid: "t", title: "Tech entry", summary: "<p>Tech summary</p>", published_at: 2.hours.ago) }

  before { driven_by :selenium, using: :headless_chrome }

  def use_viewport(width, height, mobile:)
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: width, height: height, deviceScaleFactor: 1, mobile: mobile
    )
  end

  def screenshot(name)
    page.save_screenshot(Rails.root.join("tmp/screenshots/#{name}.png")) if ENV["SCREENSHOTS"]
  end

  context "on a desktop" do
    before { use_viewport(1280, 800, mobile: false) }

    it "lists entries of all feeds on the dashboard when signed out" do
      visit "/"

      expect(page.all("main li").map(&:text)).to match([ /News.*News entry/m, /Tech.*Tech entry/m ])
      entry_window = window_opened_by { click_link "Tech entry" }
      within_window(entry_window) do
        expect(page).to have_css("h1", text: "Tech entry")
        expect(page).to have_text("Tech summary")
        expect(page).to have_css("a[aria-label='Dashboard'][aria-current='page']")
      end
    end

    it "lists subscribed entries on the dashboard and marks opened ones read when signed in" do
      user.subscribe(news)
      sign_in user

      visit "/"
      expect(page).to have_link("News entry")
      expect(page).to have_no_link("Tech entry")
      expect(page).to have_css("main p.font-medium", text: "News entry")

      entry_window = window_opened_by { click_link "News entry" }
      within_window(entry_window) { expect(page).to have_text("News summary") }
      # Reading the entry in its tab shows it as read here.
      expect(page).to have_css("main p.text-gray-400", text: "News entry")
      screenshot("desktop-dashboard")
      expect(user.read?(news_entry)).to be(true)
    end

    it "lists bookmarks when signed in" do
      user.bookmark(tech_entry)
      sign_in user

      visit "/bookmarks"
      expect(page).to have_link("Tech entry")
      expect(page).to have_no_link("News entry")

      entry_window = window_opened_by { click_link "Tech entry" }
      within_window(entry_window) do
        expect(page).to have_text("Tech summary")
        expect(page).to have_css("a[aria-label='Bookmarks'][aria-current='page']")
        screenshot("desktop-bookmarks")
      end
    end

    it "asks to sign in for bookmarks when signed out" do
      visit "/bookmarks"

      expect(page).to have_text("Sign in to see your bookmarks.")
    end
  end

  context "on a phone" do
    before { use_viewport(390, 844, mobile: true) }

    it "shows the dashboard list, then an entry with a way back" do
      visit "/"
      expect(page).to have_css("header", text: "Dashboard")
      screenshot("phone-dashboard")

      entry_window = window_opened_by { click_link "News entry" }
      within_window(entry_window) do
        # The emulated viewport is per tab.
        use_viewport(390, 844, mobile: true)
        expect(page).to have_text("News summary")
        expect(page).to have_no_css("main", visible: :visible)

        click_link "Dashboard"
        expect(page).to have_link("Tech entry")
      end
    end
  end
end
