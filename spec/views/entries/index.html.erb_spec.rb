require 'rails_helper'

RSpec.describe "entries/index", type: :view do
  before(:each) do
    assign(:entries, [
      Entry.create!(
        feed: nil,
        entry_id: "Entry",
        url: "Url",
        title: "Title",
        summary: "Summary",
        image_url: "Image Url"
      ),
      Entry.create!(
        feed: nil,
        entry_id: "Entry",
        url: "Url",
        title: "Title",
        summary: "Summary",
        image_url: "Image Url"
      )
    ])
  end

  it "renders a list of entries" do
    render
    assert_select "tr>td", text: nil.to_s, count: 2
    assert_select "tr>td", text: "Entry".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
    assert_select "tr>td", text: "Title".to_s, count: 2
    assert_select "tr>td", text: "Summary".to_s, count: 2
    assert_select "tr>td", text: "Image Url".to_s, count: 2
  end
end
