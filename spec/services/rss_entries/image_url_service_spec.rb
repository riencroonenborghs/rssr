require "rails_helper"

RSpec.describe RssEntries::ImageUrlService do
  let(:feed_entry_class) { Struct.new(:image, :content, :summary, :url, keyword_init: true) }

  def image_url(**attributes)
    described_class.call(feed_entry_class.new(**attributes))
  end

  it "uses the feed's image metadata first" do
    expect(image_url(image: "https://example.com/thumb.jpg", summary: %(<img src="https://example.com/inline.jpg">)))
      .to eq("https://example.com/thumb.jpg")
  end

  it "falls back to the first image in the content, then the summary" do
    expect(image_url(content: %(<p>Text <img src="https://example.com/a.png"><img src="https://example.com/b.png"></p>)))
      .to eq("https://example.com/a.png")
    expect(image_url(summary: %(<img src="https://example.com/s.png">))).to eq("https://example.com/s.png")
  end

  it "skips enclosures that are audio or video" do
    expect(image_url(image: "https://example.com/episode.mp3", summary: %(<img src="https://example.com/cover.jpg">)))
      .to eq("https://example.com/cover.jpg")
  end

  it "resolves relative URLs against the entry's URL" do
    expect(image_url(summary: %(<img src="/images/a.jpg">), url: "https://example.com/posts/1"))
      .to eq("https://example.com/images/a.jpg")
  end

  it "ignores non-http URLs and returns nil without an image" do
    expect(image_url(summary: %(<img src="data:image/png;base64,AAAA">))).to be_nil
    expect(image_url(summary: %(<img src="javascript:alert(1)">))).to be_nil
    expect(image_url(summary: "<p>No image</p>")).to be_nil
    expect(image_url).to be_nil
  end
end
