# frozen_string_literal: true

RSpec.describe GuessFeedDetails, type: :service do
  subject { described_class.perform(feed: feed) }

  let(:feed) { create(:feed) }
  let(:feed_data_success) { true }
  let(:feed_data_errors) { nil }
  let(:feed_data) { double(title: "title") }

  before do
    allow(GetFeedData).to receive(:perform).and_return(double(success?: feed_data_success, errors: feed_data_errors, feed_data: feed_data))
  end

  context "when getting the feed data fails" do
    let(:feed_data_success) { false }
    let(:feed_data_errors) do
      errors = ActiveModel::Errors.new(GetFeedData)
      errors.add(:base, "some error")
      errors
    end

    it "fails" do
      expect(subject).to be_failure
    end
    
    it "has an error" do
      expect(subject.errors.full_messages).to include "some error"
    end
  end

  it "succeeds" do
    expect(subject).to be_success
  end

  it "guessed the name" do
    expect(subject.name).to eq "title"
  end
end
