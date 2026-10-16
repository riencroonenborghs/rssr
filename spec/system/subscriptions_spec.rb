require "rails_helper"

RSpec.describe "Managing subscriptions", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
  end

  it "asks to sign in when signed out" do
    visit "/subscriptions"

    expect(page).to have_text("Sign in to manage your subscriptions.")
  end

  it "lists subscriptions and unsubscribes from a feed" do
    example = RssFeed.create!(url: "https://example.com/feed.xml", title: "Example")
    other = RssFeed.create!(url: "https://example.com/other.xml", title: "Other")
    user.subscribe(example)
    user.subscribe(other)
    sign_in user
    visit "/"

    click_link "Subscriptions"
    expect(page).to have_current_path("/subscriptions")
    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "Example")
    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "Other")

    click_button "Unsubscribe from Example"

    expect(page).to have_no_css("ul[aria-label=Subscriptions] li", text: "Example")
    expect(user.rss_feeds).to eq([ other ])
  end

  it "reloads a feed" do
    feed = RssFeed.create!(url: "https://example.com/feed.xml", title: "Example", error: "HTTP 500")
    user.subscribe(feed)
    stub_request(:get, feed.url).to_return(body: <<~XML)
      <?xml version="1.0"?>
      <rss version="2.0"><channel><title>Example</title><link>https://example.com</link><description>Example</description>
        <item><title>New post</title><link>https://example.com/new</link><guid>new</guid></item>
      </channel></rss>
    XML
    sign_in user
    visit "/subscriptions"
    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "HTTP 500")

    click_button "Reload Example"

    expect(page).to have_no_text("HTTP 500")
    expect(page).to have_css("ul[aria-label=Subscriptions] time", text: "now")
    expect(feed.rss_entries.pluck(:title)).to eq([ "New post" ])
  end

  it "reloads all feeds" do
    feeds = %w[one two].map do |name|
      RssFeed.create!(url: "https://example.com/#{name}.xml", title: name.capitalize, error: "HTTP 500").tap do |feed|
        user.subscribe(feed)
        stub_request(:get, feed.url).to_return(body: <<~XML)
          <?xml version="1.0"?>
          <rss version="2.0"><channel><title>#{feed.title}</title><link>https://example.com</link><description>Feed</description>
            <item><title>#{feed.title} post</title><link>https://example.com/#{name}</link><guid>#{name}</guid></item>
          </channel></rss>
        XML
      end
    end
    sign_in user
    visit "/subscriptions"
    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "HTTP 500", count: 2)

    click_button "Reload all"

    expect(page).to have_button("Reload all", disabled: false)
    expect(page).to have_no_text("HTTP 500")
    expect(feeds.map { |feed| feed.rss_entries.pluck(:title) }).to eq([ [ "One post" ], [ "Two post" ] ])
  end

  it "subscribes to a feed by URL and lists it" do
    sign_in user
    stub_request(:get, "https://example.com/feed.xml").to_return(body: <<~XML)
      <?xml version="1.0"?>
      <rss version="2.0"><channel><title>Example</title><link>https://example.com</link><description>Example</description></channel></rss>
    XML
    visit "/subscriptions"
    expect(page).to have_text("You have no subscriptions yet.")

    fill_in "URL", with: "https://example.com/feed.xml"
    click_button "Add feed"

    expect(page).to have_css("ul[aria-label=Subscriptions] li", text: "Example")
    expect(page).to have_field("URL", with: "")
    expect(user.subscribed?(RssFeed.find_by!(url: "https://example.com/feed.xml"))).to be(true)
  end

  it "shows why the feed could not be added" do
    sign_in user
    stub_request(:get, "https://example.com/missing.xml").to_return(status: 404)
    visit "/subscriptions"

    fill_in "URL", with: "https://example.com/missing.xml"
    click_button "Add feed"

    expect(page).to have_css("[role=alert]", text: "HTTP 404")
  end
end
