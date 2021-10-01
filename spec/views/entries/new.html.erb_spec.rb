require 'rails_helper'

RSpec.describe "entries/new", type: :view do
  before(:each) do
    assign(:entry, Entry.new(
      feed: nil,
      entry_id: "MyString",
      url: "MyString",
      title: "MyString",
      summary: "MyString",
      image_url: "MyString"
    ))
  end

  it "renders new entry form" do
    render

    assert_select "form[action=?][method=?]", entries_path, "post" do

      assert_select "input[name=?]", "entry[feed_id]"

      assert_select "input[name=?]", "entry[entry_id]"

      assert_select "input[name=?]", "entry[url]"

      assert_select "input[name=?]", "entry[title]"

      assert_select "input[name=?]", "entry[summary]"

      assert_select "input[name=?]", "entry[image_url]"
    end
  end
end
