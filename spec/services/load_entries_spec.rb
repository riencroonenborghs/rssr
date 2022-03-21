require "rails_helper"

RSpec.describe LoadEntries, type: :service do
  let(:feed) { create :feed }
  let(:data) { load_file_data("rss_data.xml") }

  subject { described_class.new(feed: feed) }

  before do
    allow(LoadUrl).to receive(:call).with(url: feed.url).and_return(double({ data: data }))
  end

  describe ".call" do
    it "calls LoadFeed" do
      expect(LoadFeed).to receive(:call).with(feed: feed).and_call_original
      subject.call
    end

    it "creates new entries" do
      expect do
        subject.call
      end.to change(feed.entries.reload, :count).from(0).to(25)
    end

    it "ignores existing entries" do
      subject.call
      expect do
        subject.call
      end.to_not change(feed.entries.reload, :count)
    end
  end
end
