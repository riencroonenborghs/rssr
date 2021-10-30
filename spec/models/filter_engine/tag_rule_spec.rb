require "rails_helper"

RSpec.describe FilterEngine::TagRule, type: :model do
  let(:scope) { double }
  let(:joins_feed) { double }
  let(:includes_feed) { double }
  let(:value) { "value" }

  subject { described_class.new(comparison: comparison, value: value) }

  describe ".chain" do
    context "when eq" do
      let(:comparison) { "eq" }

      it "chains with =" do
        expect(scope).to receive(:joins).with(feed: { tags: :taggings }).and_return(joins_feed)
        expect(joins_feed).to receive(:includes).with(feed: { tags: :taggings }).and_return(includes_feed)
        expect(includes_feed).to receive(:where).with("upper(tags.name) = ?", value.upcase)
        subject.chain(scope)
      end
    end

    context "when ne" do
      let(:comparison) { "ne" }

      it "chains with !=" do
        expect(scope).to receive(:joins).with(feed: { tags: :taggings }).and_return(joins_feed)
        expect(joins_feed).to receive(:includes).with(feed: { tags: :taggings }).and_return(includes_feed)
        expect(includes_feed).to receive(:where).with("upper(tags.name) != ?", value.upcase)
        subject.chain(scope)
      end
    end

    context "when something else" do
      let(:comparison) { "gt" }

      it "chains with =" do
        expect(scope).to receive(:joins).with(feed: { tags: :taggings }).and_return(joins_feed)
        expect(joins_feed).to receive(:includes).with(feed: { tags: :taggings }).and_return(includes_feed)
        expect(includes_feed).to receive(:where).with("upper(tags.name) = ?", value.upcase)
        subject.chain(scope)
      end
    end
  end
end
