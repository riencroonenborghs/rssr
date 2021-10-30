require "rails_helper"

RSpec.describe FilterEngine::DateRule, type: :model do
  let(:scope) { double }
  let(:value) { "value" }

  subject { described_class.new(comparison: comparison, value: value) }

  describe ".chain" do
    context "when eq" do
      let(:comparison) { "eq" }

      it "chains with =" do
        expect(scope).to receive(:where).with("entries.published_at = ?", value)
        subject.chain(scope)
      end
    end

    context "when ne" do
      let(:comparison) { "ne" }

      it "chains with !=" do
        expect(scope).to receive(:where).with("entries.published_at != ?", value)
        subject.chain(scope)
      end
    end

    context "when lt" do
      let(:comparison) { "lt" }

      it "chains with <" do
        expect(scope).to receive(:where).with("entries.published_at < ?", value)
        subject.chain(scope)
      end
    end

    context "when lte" do
      let(:comparison) { "lte" }

      it "chains with <" do
        expect(scope).to receive(:where).with("entries.published_at <= ?", value)
        subject.chain(scope)
      end
    end

    context "when gt" do
      let(:comparison) { "gt" }

      it "chains with >" do
        expect(scope).to receive(:where).with("entries.published_at > ?", value)
        subject.chain(scope)
      end
    end

    context "when gte" do
      let(:comparison) { "gte" }

      it "chains with >=" do
        expect(scope).to receive(:where).with("entries.published_at >= ?", value)
        subject.chain(scope)
      end
    end
  end
end
