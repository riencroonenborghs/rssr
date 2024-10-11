# frozen_string_literal: true

class GetUrlData
  include Base

  attr_reader :url, :data, :headers

  def initialize(url:)
    @url = url
  end

  def perform
    load_response
    return unless success?

    @headers = response.headers
    @data = response.body
  end

  private

  attr_reader :response

  def request_headers
    user_agent = "linux:Bootlegger:v1.0"
    user_agent += " (by #{ENV.fetch('REDDIT_USERNAME')})" if url.match?(/reddit\.com/)
    { "User-Agent" => user_agent }
  end

  def load_response
    @response = HTTParty.get(url, header: request_headers, verify: false)
  rescue StandardError => e
    errors.add(:base, e.message)
  end
end
