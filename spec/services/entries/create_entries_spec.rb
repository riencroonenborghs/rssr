RSpec.describe Entries::CreateEntries, type: :service do
  subject(:create_entries) { described_class.perform(feed: feed) }

  let(:feed) { create(:feed) }
  let(:get_feed_data_success) { true }
  let(:get_feed_data_errors) { nil }
  let(:get_feed_data_feed_data) { double(entries: feed_data_entries) }
  let(:feed_data_entries) do
    [
      Feedjira::Parser::RSSEntry.new(
        comments: "https://news.ycombinator.com/item?id=46290916",
        published: Time.parse("2025-12-16 16:54:19 UTC").iso8601,
        summary: "<a href=\"https://news.ycombinator.com/item?id=46290916\">Comments</a>",
        title: "alpr.watch",
        url: "https://alpr.watch/"
      ),
      Feedjira::Parser::RSSEntry.new(
        comments: "https://news.ycombinator.com/item?id=46293062",
        published: Time.parse("2025-12-16 19:20:17 UTC").iso8601,
        summary: "<a href=\"https://news.ycombinator.com/item?id=46293062\">Comments</a>",
        title: "No Graphics API",
        url: "https://www.sebastianaaltonen.com/blog/no-graphics-api"
      )
    ]
  end

  shared_examples "it fails with errors and without creating entries" do
    it "fails" do
      expect(create_entries).to be_failure
    end
  
    it "has error" do
      expect(create_entries.errors.full_messages).to include expected_error
    end

    it "creates no entries" do
      expect { create_entries }.not_to change(Entry, :count)
    end
  end

  before do
    allow(Feeds::GetFeedData).to receive(:perform).and_return(double(
      success?: get_feed_data_success,
      errors: get_feed_data_errors,
      feed_data: get_feed_data_feed_data
    ))
  end

  it "succeeds" do
    expect(create_entries).to be_success
  end

  context "when getting the feed data fails" do
    let(:get_feed_data_success) { false }
    let(:get_feed_data_errors) do
      errors = ActiveModel::Errors.new(Feeds::GetFeedData)
      errors.add(:base, expected_error)
      errors
    end
    let(:expected_error) { "some error" }

    it_behaves_like "it fails with errors and without creating entries"
  end

  context "when all feed data entries are new" do
    it "creates entries" do
      expect { create_entries }.to change(feed.entries, :count).by(2)
    end
  
    it "has entries with all data" do
      create_entries
      first_entry = feed.reload.entries.first
      expect(first_entry.published_at).to eq Time.parse("2025-12-16 16:54:19 UTC")
      expect(first_entry.description).to eq "<a href=\"https://news.ycombinator.com/item?id=46290916\">Comments</a>"
      expect(first_entry.title).to eq "alpr.watch"
      expect(first_entry.link).to eq "https://alpr.watch/"
      second_entry = feed.reload.entries.second
      expect(second_entry.published_at).to eq Time.parse("2025-12-16 19:20:17 UTC")
      expect(second_entry.description).to eq "<a href=\"https://news.ycombinator.com/item?id=46293062\">Comments</a>"
      expect(second_entry.title).to eq "No Graphics API"
      expect(second_entry.link).to eq "https://www.sebastianaaltonen.com/blog/no-graphics-api"
    end
  end

  context "when only some feed data entries are new" do
    before do
      feed.entries.create!(
        guid: "https://www.sebastianaaltonen.com/blog/no-graphics-api",
        published_at: Time.parse("2025-12-16 19:20:17 UTC"),
        description: "<a href=\"https://news.ycombinator.com/item?id=46293062\">Comments</a>",
        title: "No Graphics API",
        link: "https://www.sebastianaaltonen.com/blog/no-graphics-api"
      )
    end

    it "creates entries" do
      expect { create_entries }.to change(feed.entries, :count).by(1)
    end
  
    it "has entries with all data" do
      create_entries
      entry = feed.reload.entries.last
      expect(entry.published_at).to eq Time.parse("2025-12-16 16:54:19 UTC")
      expect(entry.description).to eq "<a href=\"https://news.ycombinator.com/item?id=46290916\">Comments</a>"
      expect(entry.title).to eq "alpr.watch"
      expect(entry.link).to eq "https://alpr.watch/"
    end
  end

  context "when creating entries fails" do
    let(:expected_error) { "some error" }

    before do
      errors = ActiveModel::Errors.new(Feed)
      errors.add(:base, expected_error)

      allow(feed).to receive_messages(save: false, errors: errors)
    end

    it_behaves_like "it fails with errors and without creating entries"
  end
end
