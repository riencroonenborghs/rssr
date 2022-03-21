require "rails_helper"

RSpec.describe YoutubeFeedUrl, type: :service do
  subject { described_class.new(url: anything) }

  describe ".call" do
    before do
      expect(subject).to receive(:data).and_return(data)
    end

    context "when a channel ID is not present" do
      let(:data) {  "some data" }

      it "returns a nil feed url" do
        subject.call
        expect(subject.feed_url).to be nil
      end
    end

    context "when a channel ID is present" do
      let(:data) { load_file_data("youtube_data.html") }

      it "returns the feed url" do
        subject.call
        expect(subject.feed_url).to eq "https://www.youtube.com/feeds/videos.xml?channel_id=UCyEd6QBSgat5kkC6svyjudA"
      end
    end
  end
end
