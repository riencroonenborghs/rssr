require "rails_helper"

RSpec.describe FilterEngine::KeywordRule, type: :model do
  let(:scope) { double }
  let(:value) { "value" }

  subject { described_class.new(comparison: comparison, value: value) }

  describe ".chain" do
    context "when eq" do
      let(:comparison) { "eq" }

      it "chains with like" do
        expect(scope).to receive(:where).with("upper(entries.title) like ?", "%#{value.upcase}%")
        subject.chain(scope)
      end
    end

    context "when ne" do
      let(:comparison) { "ne" }

      it "chains with not like" do
        expect(scope).to receive(:where).with("upper(entries.title) not like ?", "%#{value.upcase}%")
        subject.chain(scope)
      end
    end

    context "when something else" do
      let(:comparison) { "gt" }

      it "chains with like" do
        expect(scope).to receive(:where).with("upper(entries.title) like ?", "%#{value.upcase}%")
        subject.chain(scope)
      end
    end
  end
end
