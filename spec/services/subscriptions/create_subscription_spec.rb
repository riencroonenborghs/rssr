require "sidekiq/testing"
Sidekiq::Testing.fake!

module Subscriptions
  RSpec.describe CreateSubscription, type: :service do
    subject(:create_subscription) { described_class.perform(user: user, url: url, title: title, get_title_from_url: get_title_from_url, tag_names: tag_names) }

    let(:user) { create :user }
    let(:url) { "http://some.url.com" }
    let(:title) { "Name" }
    let(:get_title_from_url) { false }
    let(:tag_names) { "foo,bar,baz" }

    shared_examples "it fails with errors" do
      it "fails" do
        expect(create_subscription).to be_failure
      end
    
      it "has error" do
        expect(create_subscription.errors.full_messages).to include expected_error
      end
    end

    describe "#perform" do
      context "when the feed is new" do
        context "when saving the feed fails" do
          let(:expected_error) { "some feed error" }

          before do
            errors = ActiveModel::Errors.new(Feed)
            errors.add(:base, expected_error)
            feed = build :feed
            allow(feed).to receive(:save).and_return false
            allow(feed).to receive(:errors).and_return errors
            allow(Feed).to receive(:new).and_return(feed)
          end

          it_behaves_like "it fails with errors"
        end

        it "creates the feed" do
          expect { create_subscription }.to change(Feed, :count).by(1)
        end

        it "creates the feed with all the relevant detals" do
          create_subscription
          feed = Feed.last
          expect(feed.url).to eq url
          expect(feed.title).to eq title
        end

        context "when getting the title from the URL" do
          let(:get_title_from_url) { true }
          let(:other_title) { "other title" }

          before do
            allow(Feeds::GetFeedTitle).to receive(:perform).and_return(double(title: other_title))
          end

          it "fetches the title" do
            expect(Feeds::GetFeedTitle).to receive(:perform).with(url: url)
            create_subscription
          end

          it "creates the feed" do
            expect { create_subscription }.to change(Feed, :count).by(1)
          end
  
          it "creates the feed with all the relevant detals" do
            create_subscription
            feed = Feed.last
            expect(feed.url).to eq url
            expect(feed.title).to eq other_title
          end
        end
      end

      context "when feed exists" do
        let!(:feed) { create :feed, url: url }

        it "does not creates the feed" do
          expect { create_subscription }.to_not change(Feed, :count)
        end
      end

      context "when the subscription is new" do
        context "when saving the subscription fails" do
          let(:expected_error) { "some subscription error" }

          before do
            object = User.new
            object.errors.add(:base, expected_error)

            subscription = instance_double(Subscription, save: false, errors: object.errors)
            allow(user.subscriptions).to receive(:build).and_return(subscription)
          end

          it_behaves_like "it fails with errors"
        end

        it "creates the subscription" do
          expect { create_subscription }.to change { user.subscriptions.reload.count }.by(1)
        end
      end

      context "when the subscription exists" do
        let(:expected_error) { "Subscription already exists" }
        let!(:feed) { create :feed, url: url }
        let!(:subscription) { user.subscriptions.create!(feed: feed) }

        it_behaves_like "it fails with errors"
      end
    end

    it "queues a feed refresh job for later" do
      feed = create :feed, url: url
      expect(RefreshFeedJob).to receive(:perform_later).with(feed)
      create_subscription
    end
  end
end
