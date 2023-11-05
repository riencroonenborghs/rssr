require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

module Subscriptions
  RSpec.describe CreateSubscription, type: :service do
    subject { described_class.perform(user: user, name: name, tag_list: tag_list, url: url, rss_url: rss_url, description: description, hide_from_main_page: hide_from_main_page) }

    let(:user) { create :user }
    let(:name) { "Name" }
    let(:tag_list) { "foo,bar,baz" }
    let(:url) { "http://some.url.com" }
    let(:rss_url) { "http://other.url.com" }
    let(:description) { "description" }
    let(:hide_from_main_page) { false }

    describe "#perform" do
      context "when the feed is new" do
        context "when saving the feed fails" do
          let(:error_message) { "some feed error" }

          before do
            errors = ActiveModel::Errors.new(Feed)
            errors.add(:base, error_message)
            feed = build :feed
            allow(feed).to receive(:save).and_return false
            allow(feed).to receive(:errors).and_return errors
            allow(Feed).to receive(:new).and_return(feed)
          end

          it_behaves_like "the service fails"
        end

        it "creates the feed" do
          expect { subject }.to change(Feed, :count).by(1)
        end

        it "sets the rss url" do
          subject
          feed = Feed.last
          expect(feed.rss_url).to eq rss_url
        end

        it "sets the name" do
          subject
          feed = Feed.last
          expect(feed.name).to eq name
        end
      end

      context "when feed exists" do
        let!(:feed) { create :feed, url: url }

        it "does not creates the feed" do
          expect { subject }.to_not change(Feed, :count)
        end
      end

      context "when the subscription is new" do
        context "when saving the subscription fails" do
          let(:error_message) { "some subscription error" }

          before do
            object = User.new
            object.errors.add(:base, error_message)

            subscription = instance_double(Subscription, save: false, errors: object.errors)
            allow(user.subscriptions).to receive(:build).and_return(subscription)
          end

          it_behaves_like "the service fails"
        end

        it "creates the subscription" do
          expect { subject }.to change(Subscription, :count).by(1)
        end
      end

      context "when the subscription exists" do
        let(:error_message) { "subscription already exists" }
        let!(:feed) { create :feed, url: url }
        let!(:subscription) { user.subscriptions.create!(feed: feed) }

        it_behaves_like "the service fails"
      end
    end

    it "queues a feed refresh job for later" do
      feed = create :feed, url: url
      travel_to Time.zone.now do
        expect(RefreshFeedJob).to receive(:perform_in).with(5.seconds, { feed_id: feed.id }.to_json)
        subject
      end
    end
  end
end
