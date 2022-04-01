require "rails_helper"

RSpec.describe CreateSubscriptionService, type: :service do
  let(:user) { create :user }
  let(:name) { "Name" }
  let(:tag_list) { "foo,bar,baz" }
  let(:url) { Faker::Internet.url }
  let(:description) { "description" }

  subject { described_class.new(user: user, name: name, tag_list: tag_list, url: url, description: description) }

  describe "#call" do
    context "when the feed is new" do
      context "when saving the feed fails" do
        before do
          object = User.new
          object.errors.add(:base, "some feed error")

          feed = instance_double(Feed, save: false, errors: object.errors)
          allow(Feed).to receive(:new).and_return(feed)
        end

        it_behaves_like "the service fails with error", "some feed error"
      end

      it "creates the feed" do
        expect { subject.call }.to change(Feed, :count).by(1)
      end
    end

    context "when feed exists" do
      let!(:feed) { create :feed, url: url }

      it "does not creates the feed" do
        expect { subject.call }.to_not change(Feed, :count)
      end
    end

    context "when the subscription is new" do
      context "when saving the subscription fails" do
        before do
          object = User.new
          object.errors.add(:base, "some subscription error")

          subscription = instance_double(Subscription, save: false, errors: object.errors)
          allow(user.subscriptions).to receive(:build).and_return(subscription)
        end

        it_behaves_like "the service fails with error", "some subscription error"
      end

      it "creates the subscription" do
        expect { subject.call }.to change(Subscription, :count).by(1)
      end
    end

    context "when the subscription exists" do
      let!(:feed) { create :feed, url: url }
      let!(:subscription) { user.subscriptions.create!(feed: feed) }

      it_behaves_like "the service fails with error", "subscription already exists"
    end
  end

  it "queues a feed refresh job for later" do
    feed = create :feed, url: url
    travel_to Time.zone.now do
      expect(RefreshFeedJob).to receive(:perform_in).with(5.seconds, feed.id)
      subject.call
    end
  end
end
