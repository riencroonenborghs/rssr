require "rails_helper"

RSpec.describe GetUrlData, type: :service do
  subject { described_class.new(url: url) }

  let(:url) { Faker::Internet.url }
  let(:body) { "body" }
  let(:headers) { { "content-type" => "" } }
  let(:response) { instance_double(HTTParty::Response, body: body, headers: headers) }

  describe "#perform" do
    before do
      allow(HTTParty).to receive(:get).and_return(response)
    end

    context "when HTTParty fails" do
      let(:error_message) { "Some httparty error" }

      before do
        allow(HTTParty).to receive(:get).and_raise(StandardError, error_message)
      end

      it_behaves_like "the service fails"
    end

    context "when HTTParty is called" do
      context "when URL is a reddit URL" do
        let(:url) { "https://www.reddit.com/r/Wellington.rss" }
        it "is called with the correct headers" do
          expect(HTTParty).to receive(:get).with(url, { header: { "User-Agent" => "linux:RSSr:v1.0 (by #{ENV.fetch("REDDIT_USERNAME")})" }, verify: false })
          subject.perform
        end
      end

      context "when URL is not a reddit URL" do
        it "is called with the correct headers" do
          expect(HTTParty).to receive(:get).with(url, { header: { "User-Agent" => "linux:RSSr:v1.0" }, verify: false })
          subject.perform
        end
      end

      it "skips HTTPS verification" do
        expect(HTTParty).to receive(:get).with(url, { header: anything, verify: false })
        subject.perform
      end
    end

    it "returns data" do
      subject.perform
      expect(subject.data).to eq body
    end
  end
end
