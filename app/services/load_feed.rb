class LoadFeed < AppService
  attr_reader :feed, :loaded_feed

  def initialize(feed:) # rubocop:disable Lint/MissingSuper
    @feed = feed
  end

  def call
    @loaded_feed = Feedjira.parse(data)
  rescue StandardError => e
    errors.add(:feed, "cannot load #{feed.url}: #{e.message}")
  end

  private

  def data
    LoadUrl.call(url: feed.url).data
  end
end
