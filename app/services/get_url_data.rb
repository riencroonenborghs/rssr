# frozen_string_literal: true

class GetUrlData
  include Base

  attr_reader :data, :headers

  def initialize(url:)
    @url = url
  end

  def perform
    send_request
    return if failure?

    @headers = @response.headers
    @data = @response.body
  end

  private

  def request_headers
    user_agent = "linux:Bootlegger:v1.0"
    user_agent += " (by #{ENV.fetch('REDDIT_USERNAME')})" if @url.match?(/reddit\.com/)
    { "User-Agent" => user_agent }
  end

  def send_request
    @response = HTTParty.get(@url, header: request_headers, verify: false)
  rescue StandardError => e
    errors.add(:base, e.message)
  end
end
