# frozen_string_literal: true

class GetUrlData
  include Service

  attr_reader :data, :headers

  def initialize(url:)
    @url = url
  end

  def perform
    send_request
    return unless success?

    @headers = response.headers
    @data = response.body
  end

  private

  attr_reader :response

  def request_headers
    user_agent = "linux:RSSr:v1.0"
    user_agent += " (by #{ENV.fetch('REDDIT_USERNAME')})" if @url.match?(/reddit\.com/)
    { "User-Agent" => user_agent }
  end

  def send_request
    @response = HTTParty.get(@url, header: request_headers, verify: false)
  rescue StandardError => e
    add_error(e.message)
  end
end
