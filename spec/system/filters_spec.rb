require "rails_helper"

RSpec.describe "Managing filters", type: :system do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }

  before do
    driven_by :selenium, using: :headless_chrome
    page.driver.browser.execute_cdp(
      "Emulation.setDeviceMetricsOverride", width: 1280, height: 800, deviceScaleFactor: 1, mobile: false
    )
  end

  it "asks to sign in when signed out" do
    visit "/filters"

    expect(page).to have_text("Sign in to manage your filters.")
  end

  it "adds and deletes filters" do
    user.filters.create!(kind: "keyword", value: "sponsored")
    sign_in user
    visit "/"

    click_link "Filters"
    expect(page).to have_current_path("/filters")
    expect(page).to have_css("ul[aria-label=Filters] li", text: "sponsored")

    select "Regular expression", from: "Type"
    fill_in "Value", with: "\\bgiveaway\\b"
    click_button "Add filter"

    expect(page).to have_css("ul[aria-label=Filters] li", text: "\\bgiveaway\\b")
    expect(user.filters.regexp.pluck(:value)).to eq([ "\\bgiveaway\\b" ])

    click_button "Delete filter sponsored"

    expect(page).to have_no_text("sponsored")
    expect(user.filters.keyword).to be_empty
  end

  it "shows why the filter could not be added" do
    sign_in user
    visit "/filters"

    select "Regular expression", from: "Type"
    fill_in "Value", with: "("
    click_button "Add filter"

    expect(page).to have_css("[role=alert]", text: "not a valid regular expression")
  end
end
