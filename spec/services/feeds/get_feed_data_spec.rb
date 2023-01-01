require "rails_helper"

module Feeds
  RSpec.describe GetFeedData, type: :service do
    subject { described_class.new(feed: feed) }

    let(:feed) { create :feed }

    let(:mock_loader_success) { true }
    let(:mock_loader_data) { double }
    let(:mock_loader_erros) { nil }
    let(:mock_loader) { instance_double(GetUrlData, success?: mock_loader_success, data: mock_loader_data, errors: mock_loader_erros) }
    let(:feedjira_data) { double }
    let(:json_data) { JSON.parse(load_file_data("subreddit_data.json")) }

    before do
      allow(GetUrlData).to receive(:perform).and_return(mock_loader)
      allow(Feedjira).to receive(:parse).and_return(feedjira_data)
      allow(JSON).to receive(:parse).and_return(json_data)
    end

    describe "#perform" do
      context "when get URL data fails" do
        let(:error_message) { "Some URL data error" }
        let(:mock_loader_success) { false }
        let(:mock_loader_erros) do
          errors = ActiveModel::Errors.new(GetUrlData)
          errors.add(:base, error_message)
          errors
        end

        it_behaves_like "the service fails"
      end

      it "loads RSS URL data" do
        expect(GetUrlData).to receive(:perform).with(url: feed.rss_url)
        subject.perform
      end

      context "when Feedjira parsing fails" do
        let(:error_message) { "Some Feedjira eror" }

        before do
          allow(Feedjira).to receive(:parse).and_raise(StandardError, error_message)
        end

        it_behaves_like "the service fails"
      end

      it "parses with Feedjira" do
        expect(Feedjira).to receive(:parse)
        subject.perform
      end
    end
  end
end
