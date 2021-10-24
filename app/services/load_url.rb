class LoadUrl < AppService
  attr_reader :url, :data

  def initialize(url:)
    @url = url
  end

  def call
    @data = HTTParty.get(url, headers: headers)&.body
  end

  private

  def headers
    { "User-agent" => "linux:rssr:1.0" }
  end
end