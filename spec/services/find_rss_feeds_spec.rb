# frozen_string_literal: true

require "rails_helper"

RSpec.describe FindRssFeeds, type: :service do
  subject { described_class.perform(url: url) }

  let(:url) { "http://some.url.com" }
  let(:loader_success) { true }
  let(:loader_data) { "data" }
  let(:loader_errors) { nil }
  let(:loader_headers) { { "content-type" => "" } }
  let(:mock_loader) { instance_double(GetUrlData, success?: loader_success, data: loader_data, errors: loader_errors, headers: loader_headers) }

  before do
    allow(GetUrlData).to receive(:perform).and_return(mock_loader)
  end

  describe "#perform" do
    context "when there's known RSS feeds" do
      context "when it's a tumblr site" do
        let(:url) { "http://catsthatlooklikeronswanson.tumblr.com" }

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "#{url}/rss"
        end

        context "when url ends with /" do
          let(:url) { "http://catsthatlooklikeronswanson.tumblr.com/" }

          it "finds feed" do
            expect(subject.rss_feeds.size).to eq 1
          end

          it "finds the rss feed url" do
            expect(subject.rss_feeds.first.href).to eq "#{url}rss"
          end
        end
      end

      context "when it's a blogger site" do
        let(:url) { "http://althouse.blogspot.com" }

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "#{url}/feeds/posts/default"
        end

        context "when url ends with /" do
          let(:url) { "http://althouse.blogspot.com/" }

          it "finds feed" do
            expect(subject.rss_feeds.size).to eq 1
          end

          it "finds the rss feed url" do
            expect(subject.rss_feeds.first.href).to eq "#{url}feeds/posts/default"
          end
        end
      end

      context "when it's a medium site" do
        let(:url) { "https://medium.com/swlh" }

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "https://medium.com/feed/swlh"
        end
      end

      context "when it's a reddit site" do
        let(:url) { "https://www.reddit.com/r/funny" }

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "#{url}/.rss"
        end

        context "when url ends with /" do
          let(:url) { "https://www.reddit.com/r/funny/" }

          it "finds feed" do
            expect(subject.rss_feeds.size).to eq 1
          end

          it "finds the rss feed url" do
            expect(subject.rss_feeds.first.href).to eq "#{url}.rss"
          end
        end
      end
    end

    context "when there's unknown RSS feeds" do
      context "when loading the URL data fails" do
        let(:error_message) { "Some error" }
        let(:loader_success) { false }
        let(:loader_errors) do
          errors = ActiveModel::Errors.new(GetUrlData)
          errors.add(:base, error_message)
          errors
        end

        it_behaves_like "the service fails"
      end

      context "when url is already an RSS feed" do
        let(:loader_headers) { { "content-type" => "application/xml" } }

        it "loads the URL" do
          expect(GetUrlData).to receive(:perform)
          subject
        end

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds uses the URL as the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq url
        end
      end

      context "when it's a regular site with a relative rss alternate" do
        let(:loader_data) { load_file_data("relative_alternate.html") }

        it "loads the URL" do
          expect(GetUrlData).to receive(:perform)
          subject
        end

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "#{url}/rss"
        end
      end

      context "when it's a regular site with a full rss alternate" do
        let(:loader_data) { load_file_data("full_alternate.html") }

        it "loads the URL" do
          expect(GetUrlData).to receive(:perform)
          subject
        end

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "https://news.ycombinator.com/rss"
        end
      end

      context "when it's a regular site with a atom alternate" do
        let(:loader_data) { load_file_data("atom_alternate.html") }

        it "loads the URL" do
          expect(GetUrlData).to receive(:perform)
          subject
        end

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 1
        end

        it "finds the rss feed url" do
          expect(subject.rss_feeds.first.href).to eq "https://news.ycombinator.com/rss"
        end
      end

      context "when it's a regular site with multiple rss alternates" do
        let(:loader_data) { load_file_data("multiple_alternates.html") }

        it "loads the URL" do
          expect(GetUrlData).to receive(:perform)
          subject
        end

        it "finds feed" do
          expect(subject.rss_feeds.size).to eq 2
        end

        it "finds the first rss feed" do
          first = subject.rss_feeds.first
          expect(first.title).to eq "Main Feed"
          expect(first.href).to eq "https://news.ycombinator.com/rss"
        end

        it "finds the second rss feed" do
          second = subject.rss_feeds.second
          expect(second.title).to eq "Comments Feed"
          expect(second.href).to eq "https://news.ycombinator.com/comments/rss"
        end
      end

      context "when it's a regular site" do
        let(:loader_data) { load_file_data("no_alternates.html") }

        it "loads the URL" do
          expect(GetUrlData).to receive(:perform)
          subject
        end

        it "finds no feed" do
          expect(subject.rss_feeds.size).to eq 0
        end
      end
    end
  end
end
