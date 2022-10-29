require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe UpdateSubscriptionService, type: :service do
  let(:user) { create :user }
  let(:subscription) { create :subscription, user: user }
  let(:id) { subscription.id }

  let(:name) { "Name" }
  let(:tag_list) { "foo,bar,baz" }
  let(:url) { Faker::Internet.url }
  let(:description) { "description" }

  let(:params) do
    {
      name: name,
      tag_list: tag_list,
      url: url,
      description: description
    }
  end

  let(:expected_attributes) { params.update(tag_list: tag_list.split(",")) }

  subject { described_class.new(user: user, id: id, params: params) }

  describe "#call" do
    context "when the subscription does not exist" do
      let(:id) { "lolwut?!" }

      it_behaves_like "the service fails with error", "No subscription found"
    end

    context "when saving the feed fails" do
      before do
        object = User.new
        object.errors.add(:base, "some feed error")

        feed = instance_double(Feed, save: false, assign_attributes: proc {}, errors: object.errors, url_changed?: true)
        allow(subject).to receive(:subscription).and_return(subscription)
        allow(subscription).to receive(:feed).and_return(feed)
      end

      it_behaves_like "the service fails with error", "some feed error"
    end

    it "succeeds" do
      subject.call
      expect(subject).to be_success
    end

    it "updates the feed" do
      subject.call
      expect(subscription.feed.reload).to have_attributes(expected_attributes)
    end

    context "when url changes" do
      it "queues a feed refresh job for later" do
        travel_to Time.zone.now do
          expect(RefreshFeedJob).to receive(:perform_in).with(5.seconds, subscription.feed.id)
          subject.call
        end
      end
    end

    context "when url does not change" do
      let(:url) { subscription.feed.url }

      it "does not queue a feed refresh job" do
        subject.call
        expect(RefreshFeedJob).to_not receive(:perform_in)
      end
    end
  end
end
