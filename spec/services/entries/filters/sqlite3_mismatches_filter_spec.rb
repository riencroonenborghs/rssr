# frozen_string_literal: true

RSpec.describe Entries::Filters::Sqlite3Filter, type: :service do
  subject(:filter_entries) { described_class.perform(user: user, scope: scope) }
  subject(:filter_entries_instance) { described_class.new(user: user, scope: scope) }

  let(:user) { create(:user) }
  let(:mismatches_filter) { create(:filter, user: user, comparison: Filter::MISMATCHES_FILTER, value: "fo.*") }
  let(:feed) { create(:feed) }
  let(:scope) { feed.entries }

  before do
    mismatches_filter
    create(:entry, feed: feed, title: "foo bar baz")
    create(:entry, feed: feed, title: "olaf polaf")
    create(:entry, feed: feed, title: "quux qoox")
  end

  it "succeeds" do
    expect(filter_entries).to be_success
  end

  it "changes the scope" do
    expect(filter_entries_instance.scope.count).to eq 3
    filter_entries_instance.perform
    expect(filter_entries_instance.scope.count).to eq 1
  end

  it "filters" do
    expect(filter_entries.scope.pluck(:title)).to include "foo bar baz"
    expect(filter_entries.scope.pluck(:title)).not_to include "olaf polaf"
    expect(filter_entries.scope.pluck(:title)).not_to include "quux qoox"
  end

  context "when there's more than one filter" do
    let(:second_mismatches_filter) { create(:filter, user: user, comparison: Filter::MISMATCHES_FILTER, value: "po.*") }
    
    before do
      second_mismatches_filter
    end

    it "succeeds" do
      expect(filter_entries).to be_success
    end

    it "changes the scope" do
      expect(filter_entries_instance.scope.count).to eq 3
      filter_entries_instance.perform
      expect(filter_entries_instance.scope.count).to eq 2
    end

    it "filters" do
      expect(filter_entries.scope.pluck(:title)).to include "foo bar baz"
    expect(filter_entries.scope.pluck(:title)).to include "olaf polaf"
    expect(filter_entries.scope.pluck(:title)).not_to include "quux qoox"
    end
  end
end
