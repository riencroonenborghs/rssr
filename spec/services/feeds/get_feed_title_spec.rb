RSpec.describe Feeds::GetFeedTitle, type: :service do
  subject(:get_feed_title) { described_class.perform(url: url) }

  let(:url) { Faker::Internet.url }
  let(:get_feed_data_success) { true }
  let(:get_feed_data_errors) { nil }
  let(:get_feed_data_feed_data) { double(title: title) }
  let(:title) { "title" }

  shared_examples "it fails with errors and without title" do
    it "fails" do
      expect(get_feed_title).to be_failure
    end

    it "has error" do
      expect(get_feed_title.errors.full_messages).to include expected_error
    end

    it "has no title" do
      expect(get_feed_title.title).to be_nil
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
    expect(get_feed_title).to be_success
  end

  it "gets the Feed data" do
    expect(Feeds::GetFeedData).to receive(:perform).with(url: url)
    get_feed_title
  end

  it "has a title" do
    expect(get_feed_title.title).to eq title
  end

  context "when getting the feed data fails" do
    let(:get_feed_data_success) { false }
    let(:get_feed_data_errors) do
      errors = ActiveModel::Errors.new(Feeds::GetFeedData)
      errors.add(:base, expected_error)
      errors
    end
    let(:expected_error) { "some error" }

    it_behaves_like "it fails with errors and without title"
  end
end
