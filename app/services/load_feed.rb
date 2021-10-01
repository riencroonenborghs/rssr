class LoadFeed < AppService
  attr_reader :feed, :loaded_feed

  def initialize(feed:)
    @feed = feed
  end

  def call
    @loaded_feed = Feedjira.parse(xml)
  end

  private

  def xml
    HTTParty.get(feed.url, headers: headers)&.body
  end

  def headers
    { "User-agent" => "linux:rssr:1.0" }
  end
end
