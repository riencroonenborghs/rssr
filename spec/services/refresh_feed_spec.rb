# frozen_string_literal: true

RSpec.describe RefreshFeed, type: :service do
  subject { described_class.perform(feed: feed) }

  let(:feed) { create(:feed, :active) }
  let(:create_success) { true }
  let(:create_errors) { nil }

  before do
    allow(CreateEntries).to receive(:perform).and_return(double(success?: create_success, errors: create_errors))
  end

  context "when feed is inactive" do
    let(:feed) { create(:feed, :inactive) }

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "Feed not active"
    end
    
    it "updates the feed's refresh_at" do
      freeze_time do
        expect { subject }.to change { feed.refresh_at }.to(Time.zone.now)
      end
    end
  end

  context "when creating the entries fails" do
    let(:create_success) { false }
    let(:create_errors) do
      errors = ActiveModel::Errors.new(CreateEntries)
      errors.add(:base, "some error")
      errors
    end

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "Could not create entries: some error"
    end

    it "sets feed error" do
      expect { subject }.to change { feed.error }.to("some error")
    end
    
    it "updates the feed's refresh_at" do
      freeze_time do
        expect { subject }.to change { feed.refresh_at }.to(Time.zone.now)
      end
    end
  end

  it "succeeds" do
    expect(subject).to be_success
  end

  it "calls the create entries service" do
    expect(CreateEntries).to receive(:perform)
    subject
  end

  it "updates the feed's refresh_at" do
    freeze_time do
      expect { subject }.to change { feed.refresh_at }.to(Time.zone.now)
    end
  end

  it "resets the error on the feed" do
    feed.update(error: "some error")
    expect { subject }.to change { feed.error }.to(nil)
  end
end
