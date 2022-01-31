class LoadUrl < AppService
  attr_reader :url, :data

  def initialize(url:) # rubocop:disable Lint/MissingSuper
    @url = url
  end

  def call
    @data = HTTParty.get(url, verify: false)&.body
  end

  private

  def headers
    { "User-agent" => "linux:rssr:1.0" }
  end
end
