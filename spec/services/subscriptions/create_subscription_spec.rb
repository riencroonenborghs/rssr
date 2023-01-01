require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

module Subscriptions
  RSpec.describe CreateSubscription, type: :service do
    subject { described_class.perform(user: user, name: name, tag_list: tag_list, url: url, description: description, hide_from_main_page: hide_from_main_page) }

    let(:user) { create :user }
    let(:name) { "Name" }
    let(:tag_list) { "foo,bar,baz" }
    let(:url) { Faker::Internet.url }
    let(:description) { "description" }
    let(:hide_from_main_page) { false }

    let(:finder_success) { true }
    let(:rss_feed) { FindRssFeeds::RssFeed.new(href: Faker::Internet.url) }
    let(:finder_rss_feeds) { [rss_feed] }
    let(:finder_errors) { nil }
    let(:mock_finder) { instance_double(FindRssFeeds, success?: finder_success, rss_feeds: finder_rss_feeds, errors: finder_errors) }

    let(:guesser_success) { true }
    let(:guesser_name) { "name" }
    let(:guesser_errors) { nil }
    let(:mock_guesser) { instance_double(Feeds::GuessDetails, success?: guesser_success, name: guesser_name, errors: guesser_errors) }

    before do
      allow(FindRssFeeds).to receive(:perform).and_return(mock_finder)
      allow(Feeds::GuessDetails).to receive(:perform).and_return(mock_guesser)
    end

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

        it "finds the rss feed" do
          expect(FindRssFeeds).to receive(:perform)
          subject
        end

        context "when finding the RSS feeds fails" do
          let(:error_message) { "Some error" }
          let(:finder_success) { false }
          let(:finder_errors) do
            errors = ActiveModel::Errors.new(FindRssFeeds)
            errors.add(:base, error_message)
            errors
          end

          it_behaves_like "the service fails"
        end

        context "when there's no RSS feeds" do
          let(:error_message) { "no RSS feeds found" }
          let(:finder_rss_feeds) { [] }

          it_behaves_like "the service fails"
        end

        it "creates the feed" do
          expect { subject }.to change(Feed, :count).by(1)
        end

        it "sets the rss url" do
          subject
          feed = Feed.last
          expect(feed.rss_url).to eq finder_rss_feeds.first.href
        end

        it "sets the name" do
          subject
          feed = Feed.last
          expect(feed.name).to eq name
        end

        context "when no name was given" do
          let(:name) { nil }

          context "when rss feed finder has the name" do
            let(:rss_feed_name) { "name" }
            let(:rss_feed) { FindRssFeeds::RssFeed.new(href: Faker::Internet.url, title: rss_feed_name) }

            it "sets the rss finder name" do
              subject
              feed = Feed.last
              expect(feed.name).to eq rss_feed_name
            end
          end

          it "guesses the name" do
            expect(Feeds::GuessDetails).to receive(:perform)
            subject
          end

          it "sets the guesser name" do
            subject
            feed = Feed.last
            expect(feed.name).to eq guesser_name
          end

          context "when guessing the name fails" do
            let(:error_message) { "Some error" }
            let(:guesser_success) { false }
            let(:guesser_errors) do
              errors = ActiveModel::Errors.new(Feeds::GuessDetails)
              errors.add(:base, error_message)
              errors
            end
  
            it "leaves the name blank" do
              expect(subject.feed.name).to be_nil
            end
          end
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
        expect(RefreshFeedJob).to receive(:perform_in).with(5.seconds, feed.id)
        subject
      end
    end
  end
end
