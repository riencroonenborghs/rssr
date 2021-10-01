require 'rails_helper'

RSpec.describe "entries/edit", type: :view do
  before(:each) do
    @entry = assign(:entry, Entry.create!(
      feed: nil,
      entry_id: "MyString",
      url: "MyString",
      title: "MyString",
      summary: "MyString",
      image_url: "MyString"
    ))
  end

  it "renders the edit entry form" do
    render

    assert_select "form[action=?][method=?]", entry_path(@entry), "post" do

      assert_select "input[name=?]", "entry[feed_id]"

      assert_select "input[name=?]", "entry[entry_id]"

      assert_select "input[name=?]", "entry[url]"

      assert_select "input[name=?]", "entry[title]"

      assert_select "input[name=?]", "entry[summary]"

      assert_select "input[name=?]", "entry[image_url]"
    end
  end
end
