require "rails_helper"

RSpec.describe RssEntries::FilteredService do
  let(:user) { User.create!(email: "user@example.com", password: "password123") }
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml") }

  before { user.subscribe(feed) }

  def entry(title, summary: nil, feed: self.feed, published_at: nil)
    feed.rss_entries.create!(guid: SecureRandom.uuid, title: title, summary: summary, published_at: published_at)
  end

  def filtered_titles
    described_class.call(user).map(&:title)
  end

  it "returns entries of subscribed feeds only" do
    entry("Subscribed")
    entry("Not subscribed", feed: RssFeed.create!(url: "https://example.com/other.xml"))

    expect(filtered_titles).to eq([ "Subscribed" ])
  end

  it "orders entries newest first, falling back to when they were stored" do
    entry("Old", published_at: 2.days.ago)
    entry("Unpublished")
    entry("New", published_at: 1.hour.ago)

    expect(filtered_titles).to eq(%w[Unpublished New Old])
  end

  context "with keyword filters" do
    it "hides entries whose title or summary contain the keyword" do
      entry("Apple releases a phone")
      entry("Something else", summary: "<p>An apple a day</p>")
      entry("Bananas")
      user.filters.create!(kind: :keyword, value: "apple")

      expect(filtered_titles).to eq([ "Bananas" ])
    end

    it "matches case-insensitively and on word stems" do
      entry("APPLES everywhere")
      entry("Pineapple")
      user.filters.create!(kind: :keyword, value: "apple")

      expect(filtered_titles).to eq([ "Pineapple" ])
    end

    it "requires all keywords of a filter to match" do
      entry("Apple watch review")
      entry("Apple pie recipe")
      user.filters.create!(kind: :keyword, value: "apple watch")

      expect(filtered_titles).to eq([ "Apple pie recipe" ])
    end

    it "hides entries matching any of the filters" do
      entry("Rust 2.0 released")
      entry("Go 2.0 released")
      entry("Ruby 4.0 released")
      user.filters.create!(kind: :keyword, value: "rust")
      user.filters.create!(kind: :keyword, value: "go")

      expect(filtered_titles).to eq([ "Ruby 4.0 released" ])
    end

    it "treats full-text query syntax as plain words" do
      entry("Cats or dogs")
      entry("Only cats")
      user.filters.create!(kind: :keyword, value: %(cats" OR "dogs))

      expect(filtered_titles).to eq([ "Only cats" ])
    end

    it "does not match entries updated away from the keyword" do
      updated = entry("Apple news")
      user.filters.create!(kind: :keyword, value: "apple")

      updated.update!(title: "Banana news")

      expect(filtered_titles).to eq([ "Banana news" ])
    end
  end

  context "with regexp filters" do
    it "hides entries whose title or summary match the regexp" do
      entry("Episode 42: something")
      entry("Weekly", summary: "Sponsored by ACME")
      entry("Regular post")
      user.filters.create!(kind: :regexp, value: '\AEpisode \d+')
      user.filters.create!(kind: :regexp, value: "Sponsored")

      expect(filtered_titles).to eq([ "Regular post" ])
    end

    it "is case-sensitive unless the regexp says otherwise" do
      entry("sponsored post")
      entry("SPONSORED POST")
      user.filters.create!(kind: :regexp, value: "SPONSORED")

      expect(filtered_titles).to eq([ "sponsored post" ])

      user.filters.regexp.sole.update!(value: "(?i)sponsored")

      expect(filtered_titles).to be_empty
    end

    it "keeps entries without a title or summary" do
      entry(nil)
      user.filters.create!(kind: :regexp, value: ".*")

      expect(described_class.call(user).count).to eq(1)
    end
  end

  it "combines keyword and regexp filters" do
    entry("Apple news")
    entry("Episode 1")
    entry("Kept")
    user.filters.create!(kind: :keyword, value: "apple")
    user.filters.create!(kind: :regexp, value: "^Episode")

    expect(filtered_titles).to eq([ "Kept" ])
  end

  it "does not apply other users' filters" do
    entry("Apple news")
    User.create!(email: "other@example.com", password: "password123").filters.create!(kind: :keyword, value: "apple")

    expect(filtered_titles).to eq([ "Apple news" ])
  end
end
