RSpec.describe Feeds::GetFeedData, type: :service do
  subject(:get_feed_data) { described_class.perform(url: url) }

  let(:url) { Faker::Internet.url }
  let(:get_url_data_success) { true }
  let(:get_url_data_errors) { nil }
  let(:get_url_data_data) { "get_url_data_data" }
  let(:feed_data) { "feed_data" }

  shared_examples "it fails with errors and without feed data" do
    it "fails" do
      expect(get_feed_data).to be_failure
    end
  
    it "has error" do
      expect(get_feed_data.errors.full_messages).to include expected_error
    end

    it "has no feed data" do
      expect(get_feed_data.feed_data).to be_nil
    end
  end

  before do
    allow(GetUrlData).to receive(:perform).and_return(double(
      success?: get_url_data_success,
      errors: get_url_data_errors,
      data: get_url_data_data
    ))

    allow(Feedjira).to receive(:parse).and_return(feed_data)
  end

  it "succeeds" do
    expect(get_feed_data).to be_success
  end

  it "gets the URL data" do
    expect(GetUrlData).to receive(:perform).with(url: url)
    get_feed_data
  end

  it "parses the URL data" do
    expect(Feedjira).to receive(:parse).with(get_url_data_data)
    get_feed_data
  end

  it "has feed data" do
    expect(get_feed_data.feed_data).to eq feed_data
  end

  context "when getting the URL data fails" do
    let(:get_url_data_success) { false }
    let(:get_url_data_errors) do
      errors = ActiveModel::Errors.new(GetUrlData)
      errors.add(:base, expected_error)
      errors
    end
    let(:expected_error) { "some error" }

    it_behaves_like "it fails with errors and without feed data"
  end

  context "when parsing the URL data fails" do
    let(:expected_error) { "some eror" }

    before do
      allow(Feedjira).to receive(:parse).and_raise(StandardError, expected_error)
    end

    it_behaves_like "it fails with errors and without feed data"
  end
end
