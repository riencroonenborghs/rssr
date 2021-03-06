class GetFeedDataService
  include AppService

  attr_reader :feed, :feed_data

  def initialize(feed:)
    @feed = feed
  end

  def call
    load_url_data
    return unless success?

    @feed_data = Feedjira.parse(data)
  rescue StandardError => e
    errors.add(:base, e.message)
  end

  private

  attr_reader :data

  def load_url_data
    service = GetUrlDataService.call(url: feed.url)
    errors.merge!(service.errors) and return unless service.success?

    @data = service.data
  end
end
