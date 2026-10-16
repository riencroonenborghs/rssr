require "rails_helper"
require_relative "../../support/anthropic_stubs"

RSpec.describe Summaries::CreateService do
  let(:feed) { RssFeed.create!(url: "https://example.com/feed.xml", title: "Example") }

  around do |example|
    previous = ENV["ANTHROPIC_API"]
    ENV["ANTHROPIC_API"] = "test-key"
    example.run
  ensure
    ENV["ANTHROPIC_API"] = previous
  end

  def entry(title, published_at: 1.hour.ago, summary: nil)
    feed.rss_entries.create!(guid: SecureRandom.uuid, title: title, summary: summary, published_at: published_at)
  end

  def summarize(keywords: "electric cars", period: "24h")
    described_class.call(RssEntry.newest_first, keywords: keywords, period: period)
  end

  it "summarizes the matching entries of the period, newest first, with Claude" do
    older = entry("Electric cars sell well", published_at: 3.hours.ago, summary: "<p>Sales <b>doubled</b>.</p>")
    newer = entry("New electric cars announced")
    entry("Electric cars last month", published_at: 2.days.ago)
    entry("Bicycles")
    stub = stub_claude_summary("Overview [1][2]")

    result = summarize

    expect(result.summary).to eq("Overview [1][2]")
    expect(result.entries).to eq([ newer, older ])
    expect(result.total).to eq(2)
    expect(stub.with { |request|
      body = JSON.parse(request.body)
      content = body.dig("messages", 0, "content")
      request.headers["X-Api-Key"] == "test-key" &&
        request.headers["Anthropic-Beta"] == "server-side-fallback-2026-07-01" &&
        body["model"] == "claude-opus-5-5" && body["fallbacks"] == "default" && body["stream"] == true &&
        content.include?("Keywords: electric cars") && content.include?("Posts from the last 24 hours") &&
        content.include?("[1] New electric cars announced") && content.include?("[2] Electric cars sell well") &&
        content.include?("Sales doubled.") && !content.include?("last month")
    }).to have_been_requested
  end

  it "covers the longer periods" do
    entry("Electric cars last week", published_at: 6.days.ago)
    entry("Electric cars earlier", published_at: 10.days.ago)
    stub_claude_summary("Summary")

    expect(summarize(period: "week").total).to eq(1)
    expect(summarize(period: "2weeks").total).to eq(2)
  end

  it "sends only the newest entries when many match" do
    stub_const("#{described_class}::MAX_ENTRIES", 2)
    3.times { |index| entry("Electric cars #{index}", published_at: index.hours.ago) }
    stub_claude_summary("Summary")

    result = summarize

    expect(result.entries.map(&:title)).to eq([ "Electric cars 0", "Electric cars 1" ])
    expect(result.total).to eq(3)
  end

  it "does not call Claude when no entries match" do
    entry("Bicycles")

    result = summarize

    expect(result.summary).to be_nil
    expect(result.total).to eq(0)
    expect(WebMock).not_to have_requested(:post, %r{api\.anthropic\.com})
  end

  it "requires keywords and a known period" do
    expect { summarize(keywords: " ! ") }.to raise_error(described_class::Error, /keywords/)
    expect { summarize(period: "year") }.to raise_error(described_class::Error, /period/)
  end

  it "requires the API key" do
    ENV["ANTHROPIC_API"] = ""
    entry("Electric cars")

    expect { summarize }.to raise_error(described_class::Error, /Set ANTHROPIC_API/)
  end

  it "explains a rejected API key" do
    entry("Electric cars")
    stub_request(:post, %r{api\.anthropic\.com}).to_return(
      status: 401, body: { type: "error", error: { type: "authentication_error", message: "invalid x-api-key" } }.to_json,
      headers: { "Content-Type" => "application/json" }
    )

    expect { summarize }.to raise_error(described_class::Error, /was rejected/)
  end

  it "explains a refusal" do
    entry("Electric cars")
    stub_claude_summary("", stop_reason: "refusal")

    expect { summarize }.to raise_error(described_class::Error, /declined/)
  end
end
