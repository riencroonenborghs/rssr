# frozen_string_literal: true

RSpec.describe Entries::Filters::BaseFilter, type: :service do
  subject(:filter_entries) { described_class.perform(user: user, scope: scope) }
  subject(:filter_entries_instance) { described_class.new(user: user, scope: scope) }

  let(:user) { create(:user) }
  let(:tagged_filter) { create(:filter, user: user, comparison: Filter::TAGGED_FILTER, value: "foo") }
  let(:feed) { create(:feed) }
  let(:scope) { feed.entries }

  before do
    tagged_filter
    create(:entry, feed: feed, title: "foo bar baz").tap do |entry|
      entry.add_tags("foo,bar,baz")
    end
    create(:entry, feed: feed, title: "olaf polaf").tap do |entry|
      entry.add_tags("olaf,polaf")
    end
    create(:entry, feed: feed, title: "quux qoox").tap do |entry|
      entry.add_tags("quux,qoox")
    end
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
    expect(filter_entries.scope.pluck(:title)).not_to include "foo bar baz"
    expect(filter_entries.scope.pluck(:title)).to include "olaf polaf"
    expect(filter_entries.scope.pluck(:title)).to include "quux qoox"
  end

  context "when there's more than one filter" do
    let(:second_tagged_filter) { create(:filter, user: user, comparison: Filter::TAGGED_FILTER, value: "polaf") }
    
    before do
      second_tagged_filter
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
      expect(filter_entries.scope.pluck(:title)).not_to include "foo bar baz"
      expect(filter_entries.scope.pluck(:title)).not_to include "foo polaf"
      expect(filter_entries.scope.pluck(:title)).to include "quux qoox"
    end
  end
end
