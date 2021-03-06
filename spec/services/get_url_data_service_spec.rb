require "rails_helper"

RSpec.describe GetUrlDataService, type: :service do
  let(:url) { Faker::Internet.url }
  let(:body) { "body" }
  let(:response) { instance_double(HTTParty::Response, body: body) }
  subject { described_class.new(url: url) }

  describe "#call" do
    before { allow(HTTParty).to receive(:get).and_return(response) }

    context "when HTTParty fails" do
      before { allow(HTTParty).to receive(:get).and_raise(StandardError, "Some httparty error") }

      it_behaves_like "the service fails with error", "Some httparty error"
    end

    context "when HTTParty is called" do
      it "is called with headers" do
        expect(HTTParty).to receive(:get).with(url, { header: subject.send(:headers), verify: false })
        subject.call
      end

      it "skips HTTPS verification" do
        expect(HTTParty).to receive(:get).with(url, { header: anything, verify: false })
        subject.call
      end
    end

    it "returns data" do
      subject.call
      expect(subject.data).to eq body
    end
  end
end
