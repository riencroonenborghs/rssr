require 'rails_helper'

RSpec.describe "feeds/index", type: :view do
  before(:each) do
    assign(:feeds, [
      Feed.create!(
        user: nil,
        url: "Url",
        title: "Title",
        active: false
      ),
      Feed.create!(
        user: nil,
        url: "Url",
        title: "Title",
        active: false
      )
    ])
  end

  it "renders a list of feeds" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
    assert_select "tr>td", text: "Title".to_s, count: 2
    assert_select "tr>td", text: false.to_s, count: 2
  end
end
