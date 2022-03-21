require "rails_helper"

RSpec.describe Offset, type: :service do
  let(:now) { Time.zone.parse("28 Octover 2021, 18:01") }
  let(:hex) { "617A2E8C" }

  describe "#to_offset" do
    it "turns datetime into hex" do
      expect(described_class.to_offset(datetime: now)).to eq hex
    end
  end

  describe "#to_datetime" do
    it "turns hex into datetime" do
      expect(described_class.to_datetime(offset: hex)).to eq now
    end
  end
end
