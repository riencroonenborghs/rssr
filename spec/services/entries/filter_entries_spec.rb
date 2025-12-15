# frozen_string_literal: true

RSpec.describe Entries::FilterEntries, type: :service do
  subject(:filter_entries) { described_class.perform(user: user, scope: scope) }
  subject(:filter_entries_instance) { described_class.new(user: user, scope: scope) }

  let(:user) { create(:user) }
  let(:scope) { 1 }

  shared_examples "it fails with errors and without changing the scope" do
    it "fails" do
      expect(filter_entries).to be_failure
    end
  
    it "has error" do
      expect(filter_entries.errors.full_messages).to include expected_error
    end

    it "does not change scope" do
      expect(filter_entries.scope).to eq scope
    end
  end

  context "when database is sqlite" do
    let(:sqlite_success) { true }
    let(:sqlite_scope) { 2 }
    let(:sqlite_errors) { nil }

    before do
      allow(ActiveRecord::Base.connection_db_config).to receive(:adapter).and_return(described_class::SQLITE3)
      allow(Entries::Filters::Sqlite3Filter).to receive(:perform).and_return(double(
        success?: sqlite_success,
        errors: sqlite_errors,
        scope: sqlite_scope
      ))
    end

    it "succeeds" do
      expect(filter_entries).to be_success
    end

    it "calls the sqlite filter" do
      expect(Entries::Filters::Sqlite3Filter).to receive(:perform).with(user: user, scope: scope)
      filter_entries
    end

    it "changes to scope" do
      expect(filter_entries_instance.scope).to eq scope
      filter_entries_instance.perform
      expect(filter_entries_instance.scope).to eq sqlite_scope
    end

    context "when sqlite filter fails" do
      let(:sqlite_success) { false }
      let(:sqlite_errors) do
        errors = ActiveModel::Errors.new(Entries::Filters::Sqlite3Filter)
        errors.add(:base, expected_error)
        errors
      end
      let(:expected_error) { "some error" }

      it_behaves_like "it fails with errors and without changing the scope"
    end
  end

  context "when database is pg" do
    let(:pg_success) { true }
    let(:pg_scope) { 3 }
    let(:pg_errors) { nil }

    before do
      allow(ActiveRecord::Base.connection_db_config).to receive(:adapter).and_return("pg")
      allow(Entries::Filters::PgFilter).to receive(:perform).and_return(double(
        success?: pg_success,
        errors: pg_errors,
        scope: pg_scope
      ))
    end

    it "succeeds" do
      expect(filter_entries).to be_success
    end

    it "calls the pg filter" do
      expect(Entries::Filters::PgFilter).to receive(:perform).with(user: user, scope: scope)
      filter_entries
    end

    it "changes to scope" do
      expect(filter_entries_instance.scope).to eq scope
      filter_entries_instance.perform
      expect(filter_entries_instance.scope).to eq pg_scope
    end

    context "when pg filter fails" do
      let(:pg_success) { false }
      let(:pg_errors) do
        errors = ActiveModel::Errors.new(Entries::Filters::PgFilter)
        errors.add(:base, expected_error)
        errors
      end
      let(:expected_error) { "some error" }

      it_behaves_like "it fails with errors and without changing the scope"
    end
  end
end
