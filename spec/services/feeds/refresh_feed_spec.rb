RSpec.describe Feeds::RefreshFeed, type: :service do
  subject(:refresh_feed) { described_class.perform(feed: feed) }

  let(:feed) { create(:feed) }
  let(:create_entries_success) { true }
  let(:create_entries_errors) { nil }

  shared_examples "it fails with errors and updates the feed" do
    it "fails" do
      expect(refresh_feed).to be_failure
    end
  
    it "has error" do
      expect(refresh_feed.errors.full_messages).to include expected_error
    end

    it "udpates the feed error" do
      expect { refresh_feed }.to change { feed&.reload&.error }.to(expected_error)
    end

    it "updates the feed refresh_at" do
      freeze_time do
        expect { refresh_feed }.to change { feed&.reload&.refresh_at }.to(Time.zone.now)
      end
    end
  end

  before do
    allow(Entries::CreateEntries).to receive(:perform).and_return(double(
      success?: create_entries_success,
      errors: create_entries_errors
    ))
  end

  it "succeeds" do
    expect(refresh_feed).to be_success
  end

  it "creates entries" do
    expect(Entries::CreateEntries).to receive(:perform).with(feed: feed)
    refresh_feed
  end

  it "updates the feed refresh_at" do
    freeze_time do
      expect { refresh_feed }.to change { feed.reload.refresh_at }.to(Time.zone.now)
    end
  end

  context "when feed is inactive" do
    let(:feed) { create(:feed, :inactive) }
    let(:expected_error) { "Feed not active" }

    it_behaves_like "it fails with errors and updates the feed"
  end

  context "when creating entries fails" do
    let(:create_entries_success) { false }
    let(:create_entries_errors) do
      errors = ActiveModel::Errors.new(Entries::CreateEntries)
      errors.add(:base, expected_error)
      errors
    end
    let(:expected_error) { "some error" }

    it_behaves_like "it fails with errors and updates the feed"
  end
end
