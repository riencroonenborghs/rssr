require "rails_helper"

RSpec.describe FilterEngine::Engine, type: :model do
  let(:user) { create :user }

  let!(:feed) { create :feed }
  let!(:entry1) { create :entry, feed: feed, published_at: 10.days.ago }
  let!(:entry2) { create :entry, feed: feed, published_at: 9.days.ago }
  let!(:entry3) { create :entry, feed: feed, published_at: 8.days.ago }
  let!(:entry4) { create :entry, feed: feed, published_at: 7.days.ago }
  let!(:entry5) { create :entry, feed: feed, published_at: 6.days.ago }

  subject { described_class.call user: user, scope: Entry }

  describe ".call" do
    context "when there's one rule" do
      let!(:rule1) { create :keyword_rule, user: user, value: "foo" }
      let(:full_sql) { subject.scope.to_sql }
      let(:where_sql) { full_sql.split("WHERE")[1] }

      # SELECT DISTINCT \"entries\".* FROM \"entries\" WHERE (NOT ((upper(entries.title) like '%FOO%')))

      it "has no AND scope" do
        expect(where_sql.match?("AND")).to be false
      end

      it "has a NOT scope" do
        expect(where_sql.match?("NOT")).to be true
      end
    end
    context "when there's more than one rule" do
      let!(:rule1) { create :keyword_rule, user: user, value: "foo" }
      let!(:rule2) { create :keyword_rule, user: user, value: "bar" }
      let!(:rule3) { create :keyword_rule, user: user, value: "olaf" }
      let!(:rule4) { create :keyword_rule, user: user, value: "polaf" }
      let!(:rule5) { create :keyword_rule, user: user, value: "quux" }
      let(:full_sql) { subject.scope.to_sql }
      let(:where_sql) { full_sql.split("WHERE")[1] }

      # SELECT DISTINCT \"entries\".* FROM \"entries\" WHERE (NOT ((upper(entries.title) like '%FOO%') AND (upper(entries.title) like '%BAR%') AND (upper(entries.title) like '%OLAF%') AND (upper(entries.title) like '%POLAF%') AND (upper(entries.title) like '%QUUX%')))"

      it "has a AND scope" do
        expect(where_sql.match?("AND")).to be true
      end

      it "has AND scopes" do
        expect(where_sql.split("AND").count).to eq 4 + 1 # 1 for user id and 4 for AND between the rules
      end

      it "has a NOT scope" do
        expect(where_sql.match?("NOT")).to be true
      end
    end
  end
end
