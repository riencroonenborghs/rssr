require "rails_helper"

RSpec.describe GetFeedDataService, type: :service do
  let(:feed) { create :feed }
  let(:data) { load_file_data("rss_data.xml") }
  let(:feed_data) { double }

  subject { described_class.new(feed: feed) }

  describe "#call" do
    before do
      service = instance_double(GetUrlDataService, success?: true, data: data)
      allow(GetUrlDataService).to receive(:call).with(url: feed.url).and_return(service)
      allow(Feedjira).to receive(:parse).with(data).and_return(feed_data)
    end

    context "when get URL data fails" do
      before do
        object = User.new
        object.errors.add(:base, "Some URL data error")

        service = instance_double(GetUrlDataService, success?: false, errors: object.errors)
        allow(GetUrlDataService).to receive(:call).with(url: feed.url).and_return(service)
      end

      it_behaves_like "the service fails with error", "Some URL data error"
    end

    context "when Feedjira parsing fails" do
      before do
        allow(Feedjira).to receive(:parse).with(data).and_raise(StandardError, "Some Feedjira eror")
      end

      it_behaves_like "the service fails with error", "Some Feedjira eror"
    end

    it "has feed data" do
      subject.call
      expect(subject.feed_data).to eq feed_data
    end
  end
end
