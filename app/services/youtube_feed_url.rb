class YoutubeFeedUrl < AppService
  attr_reader :url, :feed_url

  def initialize(url:) # rubocop:disable Lint/MissingSuper
    @url = url
  end

  def call
    find_channel_id
  end

  private

  def data
    LoadUrl.call(url: url).data
  end

  # rubocop:disable Style/RedundantRegexpEscape
  # rubocop:disable Style/RegexpLiteral
  def find_channel_id
    matches = data.match(/https\:\/\/www\.youtube\.com\/feeds\/videos\.xml\?channel_id=([a-zA-Z0-9_-]*)/)
    return unless matches

    @feed_url = matches[0]
    nil
  end
  # rubocop:enable Style/RedundantRegexpEscape
  # rubocop:enable Style/RegexpLiteral
end
