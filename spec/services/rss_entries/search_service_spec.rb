require "rails_helper"

RSpec.describe RssEntries::SearchService do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }

  def entry(title, summary: nil)
    feed.rss_entries.create!(guid: SecureRandom.uuid, title: title, summary: summary)
  end

  def search(query)
    described_class.call(RssEntry.all, query).map(&:title)
  end

  it "matches words in the title or summary, case-insensitively and on stems" do
    entry("Apple releases a phone")
    entry("Fruit", summary: "<p>Apples and pears</p>")
    entry("Bananas")

    expect(search("APPLE")).to contain_exactly("Apple releases a phone", "Fruit")
  end

  it "requires every word" do
    entry("Apple watch review")
    entry("Apple pie recipe")

    expect(search("apple watch")).to eq([ "Apple watch review" ])
  end

  it "matches the last word as a prefix, for searching while typing" do
    entry("Programming in Ruby")

    expect(search("progr")).to eq([ "Programming in Ruby" ])
    expect(search("ruby progr")).to eq([ "Programming in Ruby" ])
  end

  it "treats full-text query syntax as plain words" do
    entry("Cats or dogs")
    entry("Only cats")

    expect(search(%(cats" OR "dogs))).to eq([ "Cats or dogs" ])
    expect { search('NEAR( "* ^') }.not_to raise_error
  end

  it "matches nothing without words" do
    entry("Anything")

    expect(search("")).to be_empty
    expect(search(" !? ")).to be_empty
    expect(search(nil)).to be_empty
  end

  it "only searches within the given entries" do
    entry("Apple news")
    other = RssFeed.create!(url: "https://example.com/other.xml")
    other.rss_entries.create!(guid: "a", title: "Apple elsewhere")

    expect(described_class.call(feed.rss_entries, "apple").map(&:title)).to eq([ "Apple news" ])
  end
end
