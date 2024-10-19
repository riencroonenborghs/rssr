# frozen_string_literal: true

RSpec.describe GetUrlData, type: :service do
  subject { described_class.perform(url: url) }

  let(:url) { Faker::Internet.url }
  let(:status) { 200 }
  let(:body) { "body" }
  let(:request_headers) { { "User-Agent" => "linux:Bootlegger:v1.0" } }
  let(:response_headers) { { "foo" => "bar" } }

  before do
    stub_request(:get, url).with(headers: request_headers).to_return(status: status, body: body, headers: response_headers)
  end

  context "when sending the request fails" do
    before do
      stub_request(:get, url).to_raise("Some error")
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
      expect(subject.errors.full_messages).to include "Could not get url data: #{status} #{body}"
    end
  end

  it "succeeds" do
    expect(subject).to be_success
  end

  it "has the headers" do
    expect(subject.headers).to eq response_headers
  end

  it "has the data" do
    expect(subject.data).to eq body
  end
end
