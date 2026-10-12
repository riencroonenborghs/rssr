require "rails_helper"

RSpec.describe RssFeed do
  it "strips the URL and title, storing a blank title as nil" do
    feed = described_class.new(url: " https://example.com/feed.xml ", title: "  ")

    expect(feed).to have_attributes(url: "https://example.com/feed.xml", title: nil)
  end

  it "requires an http or https URL" do
    expect(described_class.new(url: "https://example.com/feed.xml")).to be_valid
    expect(described_class.new(url: "ftp://example.com/feed.xml")).not_to be_valid
    expect(described_class.new(url: "example.com/feed.xml")).not_to be_valid
  end

  it "displays its title, or its URL without one" do
    expect(described_class.new(url: "https://example.com/a.xml", title: "A").display_title).to eq("A")
    expect(described_class.new(url: "https://example.com/a.xml").display_title).to eq("https://example.com/a.xml")
  end

  it "orders by title, case-insensitively, falling back to the URL" do
    zebra = described_class.create!(url: "https://example.com/z.xml", title: "Zebra")
    apple = described_class.create!(url: "https://example.com/a.xml", title: "apple")
    untitled = described_class.create!(url: "https://example.com/m.xml")

    expect(described_class.by_title).to eq([ apple, untitled, zebra ])
  end
end
