require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe UpdateSubscription, type: :service do
  let(:user) { create :user }
  let(:subscription) { create :subscription, user: user }
  let(:id) { subscription.id }

  let(:name) { "Name" }
  let(:tag_list) { "foo,bar,baz" }
  let(:url) { Faker::Internet.url }
  let(:description) { "description" }
  let(:hide_from_main_page) { true }

  let(:params) do
    {
      name: name,
      tag_list: tag_list,
      url: url,
      description: description,
      hide_from_main_page: hide_from_main_page
    }
  end

  subject { described_class.new(user: user, id: id, params: params) }

  describe "#perform" do
    context "when the subscription does not exist" do
      let(:id) { "lolwut?!" }

      it_behaves_like "the service fails with error", "No subscription found"
    end

    context "when saving the feed fails" do
      before do
        feed = Feed.new
        allow(feed).to receive(:save).and_return(false)
        feed.errors.add(:base, "some feed error")
        allow(subject).to receive(:subscription).and_return(subscription)
        allow(subscription).to receive(:feed).and_return(feed)
      end

      it_behaves_like "the service fails with error", "some feed error"
    end

    it "succeeds" do
      subject.perform
      expect(subject).to be_success
    end

    it "updates the susbcription" do
      expected_attributes = { hide_from_main_page: hide_from_main_page }
      subject.perform
      expect(subscription.reload).to have_attributes(expected_attributes)
    end

    it "updates the feed" do
      params.delete(:hide_from_main_page)
      expected_attributes = params
      subject.perform
      tag_list = params.delete(:tag_list)
      feed = subscription.feed.reload
      expect(feed).to have_attributes(expected_attributes)
      tag_list.split(",").each do |tag|
        expect(feed.tag_list).to include tag
      end
    end

    context "when url changes" do
      it "queues a feed refresh job for later" do
        travel_to Time.zone.now do
          expect(RefreshFeedJob).to receive(:perform_in).with(5.seconds, subscription.feed.id)
          subject.perform
        end
      end
    end

    context "when url does not change" do
      let(:url) { subscription.feed.url }

      it "does not queue a feed refresh job" do
        subject.perform
        expect(RefreshFeedJob).to_not receive(:perform_in)
      end
    end
  end
end
