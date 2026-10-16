require "rails_helper"
require_relative "../support/anthropic_stubs"

RSpec.describe "Summarizing posts", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Example") }

  around do |example|
    previous = ENV.fetch("ANTHROPIC_API", nil)
    ENV["ANTHROPIC_API"] = "test-key"
    example.run
  ensure
    ENV["ANTHROPIC_API"] = previous
  end

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
  end

  it "asks to sign in when signed out" do
    visit "/summary"

    expect(page).to have_text("Sign in to summarize posts.")
  end

  it "summarizes matching posts, linking the cited ones" do
    user.subscribe(feed)
    entry = feed.rss_entries.create!(guid: "1", title: "Electric cars sell well", published_at: 2.days.ago)
    stub_claude_summary("Sales are up.\n\n## Sales\n- Electric car sales doubled [1]")
    sign_in user
    visit "/"

    click_link "Summary"
    fill_in "Keywords", with: "electric"
    choose "Week", allow_label_click: true
    click_button "Summarize"

    within("article[aria-label=Summary]") do
      expect(page).to have_text("Sales are up.")
      expect(page).to have_css("h2", text: "Sales")
      expect(page).to have_css("li", text: "Electric car sales doubled")
      click_link "[1]"
    end
    expect(page).to have_current_path("/entries/#{entry.id}")
  end

  it "lists the summarized posts and says when none match" do
    user.subscribe(feed)
    feed.rss_entries.create!(guid: "1", title: "Electric cars sell well", published_at: 2.days.ago)
    stub_claude_summary("Summary [1]")
    sign_in user
    visit "/summary"

    fill_in "Keywords", with: "electric"
    click_button "Summarize"
    expect(page).to have_text("No posts match these keywords in this period.")

    choose "2 weeks", allow_label_click: true
    click_button "Summarize"
    expect(page).to have_css("ol[aria-label='Summarized posts'] li", text: "Electric cars sell well")
    expect(page).to have_text(/1 post/i)
  end
end
