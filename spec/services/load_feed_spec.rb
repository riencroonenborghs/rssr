require "rails_helper"

RSpec.describe LoadFeed, type: :model do
  let(:feed) { create :feed }
  let(:data) { load_file_data("rss_data.xml") }

  subject { described_class.new(feed: feed) }

  describe ".call" do
    it "calls LoadUrl" do
      expect(LoadUrl).to receive(:call).with(url: feed.url).and_return(double({ data: data }))
      subject.call
    end

    it "calls Feedjira" do
      allow(LoadUrl).to receive(:call).with(url: feed.url).and_return(double({ data: data }))
      expect(Feedjira).to receive(:parse).with(data)
      subject.call
    end
  end
end
