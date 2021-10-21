class YoutubeFeedUrl < AppService
  attr_reader :url, :feed_url

  def initialize(url:)
    @url = url
  end

  def call
    find_channel_id
  end

  private

  def data
    LoadUrl.call(url: url).data
  end

  def find_channel_id
    matches = data.match(/https\:\/\/www\.youtube\.com\/feeds\/videos\.xml\?channel_id=([a-zA-Z0-9_-]*)/)
    return unless matches

    @feed_url = matches[0]
    nil
  end
end