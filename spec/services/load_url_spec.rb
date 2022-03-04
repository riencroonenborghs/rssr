require "rails_helper"

RSpec.describe LoadUrl, type: :model do
  subject { described_class.new(url: anything) }

  describe ".call" do
    it "calls HTTParty" do
      expect(HTTParty).to receive(:get)
      subject.call
    end

    it "skips https cert verification" do
      expect(HTTParty).to receive(:get).with(anything, { verify: false })
      subject.call
    end
  end
end
