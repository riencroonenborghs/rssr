require "rails_helper"

RSpec.describe FilterEngine::Engine, type: :model do
  let(:user) { create :user }

  let!(:feed) { create :feed, user: user }
  let!(:entry1) { create :entry, feed: feed, published_at: 10.days.ago }
  let!(:entry2) { create :entry, feed: feed, published_at: 9.days.ago }
  let!(:entry3) { create :entry, feed: feed, published_at: 8.days.ago }
  let!(:entry4) { create :entry, feed: feed, published_at: 7.days.ago }
  let!(:entry5) { create :entry, feed: feed, published_at: 6.days.ago }

  subject { described_class.call user: user, scope: Entry }

  describe ".call" do
    context "when there's one group" do
      let!(:rule1) { create :keyword_rule, user: user, value: "foo", group_id: 1 }
      let!(:rule2) { create :keyword_rule, user: user, value: "bar", group_id: 1 }
      # "SELECT \"entries\".* FROM \"entries\" INNER JOIN \"feeds\" ON \"feeds\".\"id\" = \"entries\".\"feed_id\" INNER JOIN \"users\" ON \"users\".\"id\" = \"feeds\".\"user_id\" WHERE (users.id = 1) AND (upper(entries.title) like '%FOO%') AND (upper(entries.title) like '%BAR%')"
      let(:full_sql) { subject.scope.to_sql }
      # "(users.id = 1) AND (upper(entries.title) like '%FOO%') AND (upper(entries.title) like '%BAR%')"
      let(:where_sql) { full_sql.split("WHERE")[1] }

      it "has no OR scope" do
        expect(where_sql.match("OR")).to be nil
      end
      it "has an AND scopes for the user and per rule" do
        # two for the two rules
        expect(where_sql.split("AND").count).to eq 2
      end
    end
    context "when there's more than one group" do
      let!(:rule1) { create :keyword_rule, user: user, value: "foo", group_id: 1 }
      let!(:rule2) { create :keyword_rule, user: user, value: "bar", group_id: 1 }
      let!(:rule3) { create :keyword_rule, user: user, value: "olaf", group_id: 2 }
      let!(:rule4) { create :keyword_rule, user: user, value: "polaf", group_id: 2 }
      let!(:rule5) { create :keyword_rule, user: user, value: "quux", group_id: 3 }
      # "SELECT \"entries\".* FROM \"entries\" INNER JOIN \"feeds\" ON \"feeds\".\"id\" = \"entries\".\"feed_id\" INNER JOIN \"users\" ON \"users\".\"id\" = \"feeds\".\"user_id\" WHERE (users.id = 1) AND (((upper(entries.title) like '%FOO%') AND (upper(entries.title) like '%BAR%') OR (upper(entries.title) like '%OLAF%') AND (upper(entries.title) like '%POLAF%')) OR (upper(entries.title) like '%QUUX%'))"
      let(:full_sql) { subject.scope.to_sql }
      # "(users.id = 1) AND (((upper(entries.title) like '%FOO%') AND (upper(entries.title) like '%BAR%') OR (upper(entries.title) like '%OLAF%') AND (upper(entries.title) like '%POLAF%')) OR (upper(entries.title) like '%QUUX%'))"
      let(:where_sql) { full_sql.split("WHERE")[1] }
      let(:or_scopes) { where_sql.split("OR") }

      it "has an OR scope per group" do
        expect(or_scopes.count).to eq 3
      end
      it "has correct AND scopes per group" do
        expect(or_scopes[0].split("AND").count).to eq 2 # two for the rules on group 1
        expect(or_scopes[1].split("AND").count).to eq 2 # two for the rules on group 2
        expect(or_scopes[2].split("AND").count).to eq 1 # none for the rules on group 3 (just the one, but split return the input)
      end
    end
  end
end
