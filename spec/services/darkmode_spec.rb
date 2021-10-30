require "rails_helper"

RSpec.describe Darkmode, type: :model do
  let(:morning) { Time.zone.parse("28 Oct 2021, 06:00 am") }
  let(:noonish) { Time.zone.parse("28 Oct 2021, 1:00 pm") }
  let(:evening) { Time.zone.parse("28 Oct 2021, 09:00 pm") }

  let(:sunrise) { Time.zone.parse("28 Oct 2021, 07:46 am") }
  let(:sunset) { Time.zone.parse("28 Oct 2021, 6:22 pm") }

  before do
    allow_any_instance_of(SolarEventCalculator).to receive(:compute_official_sunrise).and_return(sunrise)
    allow_any_instance_of(SolarEventCalculator).to receive(:compute_official_sunset).and_return(sunset)
  end

  describe "#darkmode?" do
    it "returns true before sunrise" do
      travel_to morning do
        expect(described_class.darkmode?).to be true
      end
    end

    it "returns true after sunset" do
      travel_to evening do
        expect(described_class.darkmode?).to be true
      end
    end

    it "returns false between sunrise and sunset" do
      travel_to noonish do
        expect(described_class.darkmode?).to be false
      end
    end
  end
end
