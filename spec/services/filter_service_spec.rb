require "rails_helper"

RSpec.describe FilterService, type: :service do
  let(:user) { create :user }
  let(:scope) { Entry.where(id: 1) }

  subject { described_class.call user: user, scope: scope }

  describe "#call" do
    context "when there's an eq filter" do
      let!(:filter) { create :filter, user: user, comparison: "eq", value: "foo" }

      it "calls the filter scope" do
        expect(Entry).to receive(:filter).with("!foo").and_call_original
        subject
      end
    end

    context "when there's a ne filter" do
      let!(:filter) { create :filter, user: user, comparison: "ne", value: "foo" }

      it "calls the filter scope" do
        expect(Entry).to receive(:filter).with("foo").and_call_original
        subject
      end
    end
  end
end
