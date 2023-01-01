# frozen_string_literal: true

require "nokogiri"

class FindRssFeeds
  include Base

  ATOM_XML = "application/atom+xml"
  RSS_XML = "application/rss+xml"

  RssFeed = Struct.new(:href, :title, keyword_init: true)

  attr_reader :rss_feeds

  def initialize(url:)
    @url = url
    @rss_feeds = []
  end

  def perform
    find_tumblr and return if tumblr?
    find_blogger and return if blogger?
    find_medium and return if medium?
    find_reddit and return if reddit?

    load_url_data
    return unless success?

    rss_feeds.push(RssFeed.new(href: url)) and return if rss?
    find_alternate_link
  end

  private

  attr_reader :url, :url_loader, :data

  def tumblr?
    url.match?(/tumblr/)
  end

  def find_tumblr
    href = find_href(suffix: "rss")
    @rss_feeds << RssFeed.new(href: href)
  end

  def blogger?
    url.match?(/blogspot\.com/)
  end

  def find_blogger
    href = find_href(suffix: "feeds/posts/default")
    @rss_feeds << RssFeed.new(href: href)
  end

  def medium?
    url.match?(/medium\.com/)
  end

  def find_medium
    pre, post = url.split(/medium\.com/)
    href = "#{pre}medium.com/feed#{post}"
    @rss_feeds << RssFeed.new(href: href)
  end

  def reddit?
    url.match?(/reddit\.com/)
  end

  def find_reddit
    href = find_href(suffix: ".rss")
    @rss_feeds << RssFeed.new(href: href)
  end

  def load_url_data
    @url_loader = GetUrlData.perform(url: url)
    errors.merge!(url_loader.errors) unless url_loader.success?

    @data = url_loader.data
    errors.add(:base, "URL has no data") unless data
  end

  def rss?
    url_loader.headers["content-type"].match?(/application\/(rss|xml)/)
  end

  def find_alternate_link
    # <link rel="alternate" type="application/rss+xml" title="RSS" href="rss">
    document = Nokogiri::HTML.parse(data)
    rss_alternates = document.css("link[rel='alternate']").select do |alternate|
      type = alternate.attributes["type"]&.value
      [ATOM_XML, RSS_XML].include?(type)
    end
    errors.add(:base, "no RSS URL found") and return unless rss_alternates

    if rss_alternates.size == 1
      rss_feeds << RssFeed.new(href: rss_link(rss_alternates.first))
    else
      rss_alternates.each do |rss_alternate|
        rss_feeds << RssFeed.new(
          href: rss_link(rss_alternate),
          title: rss_alternate["title"]
        )
      end
    end
  end

  def rss_link(rss_alternate)
    href = rss_alternate["href"]
    return href if href.include?("http")

    find_href(suffix: href)
  end

  def find_href(suffix:)
    url.ends_with?("/") ? "#{url}#{suffix}" : "#{url}/#{suffix}"
  end
end
