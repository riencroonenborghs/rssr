# frozen_string_literal: true

RSpec.describe SendToDownloader, type: :service do
  subject { described_class.perform(url: url) }

  let(:url) { "url" }
  let(:downloader_url) { Faker::Internet.url }
  let(:status) { 200 }
  let(:body) { "body" }

  before do
    allow(ENV).to receive(:fetch).with("DOWNLOADER_URL").and_return(downloader_url)
    stub_request(:post, downloader_url).to_return(status: status, body: body)
  end

  context "when sending the request fails" do
    before do
      stub_request(:post, downloader_url).to_raise("Some error")
    end

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "Some error"
    end
  end

  context "when request failed" do
    let(:status) { 500 }

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "Could not send to downloader: #{status} #{body}"
    end
  end

  it "succeeds" do
    expect(subject).to be_success
  end
end
