require "rails_helper"

module Entries
  RSpec.describe FilterEntries, type: :service do
    # let(:user) { create :user }

    # let!(:feed) { create :feed }
    # let!(:entry1) { create :entry, feed: feed, published_at: 10.days.ago }
    # let!(:entry2) { create :entry, feed: feed, published_at: 9.days.ago }
    # let!(:entry3) { create :entry, feed: feed, published_at: 8.days.ago }
    # let!(:entry4) { create :entry, feed: feed, published_at: 7.days.ago }
    # let!(:entry5) { create :entry, feed: feed, published_at: 6.days.ago }

    # subject { described_class.perform user: user, scope: Entry }

    # describe ".perform" do
    #   context "when there's one filter" do
    #     let!(:filter1) { create :filter, user: user, value: "foo" }
    #     let(:full_sql) { subject.scope.to_sql }
    #     let(:where_sql) { full_sql.split("WHERE")[1] }

    #     # SELECT DISTINCT \"entries\".* FROM \"entries\" WHERE (NOT ((upper(entries.title) like '%FOO%')))

    #     it "has no OR scope" do
    #       expect(where_sql.match?("OR")).to be false
    #     end

    #     it "has a NOT scope" do
    #       expect(where_sql.match?("NOT")).to be true
    #     end
    #   end
    #   context "when there's more than one filter" do
    #     let!(:filter1) { create :filter, user: user, value: "foo" }
    #     let!(:filter2) { create :filter, user: user, value: "bar" }
    #     let!(:filter3) { create :filter, user: user, value: "olaf" }
    #     let!(:filter4) { create :filter, user: user, value: "polaf" }
    #     let!(:filter5) { create :filter, user: user, value: "quux" }
    #     let(:full_sql) { subject.scope.to_sql }
    #     let(:where_sql) { full_sql.split("WHERE")[1] }

    #     # SELECT DISTINCT \"entries\".* FROM \"entries\" WHERE (NOT ((upper(entries.title) like '%FOO%') AND (upper(entries.title) like '%BAR%') AND (upper(entries.title) like '%OLAF%') AND (upper(entries.title) like '%POLAF%') AND (upper(entries.title) like '%QUUX%')))"

    #     it "has a OR scope" do
    #       expect(where_sql.match?("OR")).to be true
    #     end

    #     it "has OR scopes" do
    #       expect(where_sql.split("OR").count).to eq 4 + 1 # 1 for user id and 4 for AND between the filters
    #     end

    #     it "has a NOT scope" do
    #       expect(where_sql.match?("NOT")).to be true
    #     end
    #   end
    # end
  end
end
