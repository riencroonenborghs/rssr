# frozen_string_literal: true

RSpec.describe Entries::Filters::Sqlite3Filter, type: :service do
  subject(:filter_entries) { described_class.perform(user: user, scope: scope) }
  subject(:filter_entries_instance) { described_class.new(user: user, scope: scope) }

  let(:user) { create(:user) }

  context "when user has no filters" do
    let(:scope) { 1 }

    it "succeeds" do
      expect(filter_entries).to be_success
    end

    it "does not change the scope" do
      expect(filter_entries_instance.scope).to eq scope
      filter_entries_instance.perform
      expect(filter_entries_instance.scope).to eq scope
    end
  end
end
