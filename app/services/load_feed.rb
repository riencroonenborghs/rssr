class LoadFeed < AppService
  attr_reader :feed, :loaded_feed

  def initialize(feed:) # rubocop:disable Lint/MissingSuper
    @feed = feed
  end

  def call
    @loaded_feed = Feedjira.parse(data)
  end

  private

  def data
    LoadUrl.call(url: feed.url).data
  end
end
