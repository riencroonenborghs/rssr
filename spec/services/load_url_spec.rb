require "rails_helper"

RSpec.describe LoadUrl, type: :model do
  let(:headers) { { "User-agent" => "linux:rssr:1.0" } }
  subject { described_class.new(url: anything) }

  describe ".call" do
    it "calls HTTParty" do
      expect(HTTParty).to receive(:get)
      subject.call
    end

    it "uses custom headers" do
      expect(HTTParty).to receive(:get).with(anything, { headers: headers })
      subject.call
    end
  end
end
