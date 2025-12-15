RSpec.describe GetUrlData, type: :service do
  subject(:get_url_data) { described_class.perform(url: url) }

  let(:url) { Faker::Internet.url }
  let(:body) { "body" }
  let(:headers) { "headers" }
  let(:response) { instance_double(HTTParty::Response, body: body, headers: headers) }

  shared_examples "it fails with errors and without data or headers" do
    it "fails" do
      expect(get_url_data).to be_failure
    end
  
    it "has error" do
      expect(get_url_data.errors.full_messages).to include expected_error
    end

    it "has no data" do
      expect(get_url_data.data).to be_nil
    end

    it "has no headers" do
      expect(get_url_data.headers).to be_nil
    end
  end

  before do
    stub_const("ENV", { "REDDIT_USERNAME" => "reddit username" })
    allow(HTTParty).to receive(:get).and_return(response)
  end
  
  it "succeeds" do
    expect(get_url_data).to be_success
  end

  it "gets data" do
    expect(HTTParty).to receive(:get).with(url, header: anything, verify: false)
    get_url_data
  end

  it "has data" do
    expect(get_url_data.data).to eq body
  end

  it "has headers" do
    expect(get_url_data.headers).to eq headers
  end

  context "when HTTParty fails" do
    let(:expected_error) { "Some error" }

    before do
      allow(HTTParty).to receive(:get).and_raise(StandardError, expected_error)
    end

    it_behaves_like "it fails with errors and without data or headers"
  end

  context "when URL is a reddit URL" do
    let(:url) { "https://www.reddit.com/r/Wellington.rss" }

    it "gets data" do
      expected_headers = { "User-Agent" => "linux:RSSr:v1.0 (by reddit username)" }
      expect(HTTParty).to receive(:get).with(url, header: expected_headers, verify: false)
      get_url_data
    end
  end

  context "when URL is not a reddit URL" do
    it "gets data" do
      expected_headers = { "User-Agent" => "linux:RSSr:v1.0" }
      expect(HTTParty).to receive(:get).with(url, header: expected_headers, verify: false)
      get_url_data
    end
  end
end
