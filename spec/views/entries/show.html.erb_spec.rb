require 'rails_helper'

RSpec.describe "entries/show", type: :view do
  before(:each) do
    @entry = assign(:entry, Entry.create!(
      feed: nil,
      entry_id: "Entry",
      url: "Url",
      title: "Title",
      summary: "Summary",
      image_url: "Image Url"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Entry/)
    expect(rendered).to match(/Url/)
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Summary/)
    expect(rendered).to match(/Image Url/)
  end
end
