require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

module Subscriptions
  RSpec.describe CreateSubscription, type: :service do
    subject { described_class.new(user: user, name: name, tag_list: tag_list, url: url, description: description) }

    let(:user) { create :user }
    let(:name) { "Name" }
    let(:tag_list) { "foo,bar,baz" }
    let(:url) { Faker::Internet.url }
    let(:description) { "description" }

    let(:mock_guess_success) { true }
    let(:mock_guess_name) { "name" }
    let(:mock_guess_errors) { nil }
    let(:mock_guess) { instance_double(Feeds::GuessDetails, success?: mock_guess_success, name: mock_guess_name, errors: mock_guess_errors) }

    before do
      allow(Feeds::GuessDetails).to receive(:perform).and_return(mock_guess)
    end

    describe "#perform" do
      context "when the feed is new" do
        context "when saving the feed fails" do
          before do
            errors = ActiveModel::Errors.new(Feed)
            errors.add(:base, "some feed error")
            feed = build :feed
            allow(feed).to receive(:save).and_return false
            allow(feed).to receive(:errors).and_return errors
            allow(Feed).to receive(:new).and_return(feed)
          end

          it_behaves_like "the service fails with error", "some feed error"
        end

        it "creates the feed" do
          expect { subject.perform }.to change(Feed, :count).by(1)
        end

        it "guesses the name" do
          expect(Feeds::GuessDetails).to receive(:perform)
          subject.perform
        end
      end

      context "when feed exists" do
        let!(:feed) { create :feed, url: url }

        it "does not creates the feed" do
          expect { subject.perform }.to_not change(Feed, :count)
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
          expect { subject.perform }.to change(Subscription, :count).by(1)
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
        subject.perform
      end
    end
  end
end