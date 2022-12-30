# frozen_string_literal: true

class GetUrlData
  include Base

  attr_reader :url, :data

  def initialize(url:)
    @url = url
  end

  def perform
    load_response
    return unless success?

    @data = response.body
  end

  private

  attr_reader :response

  def headers
    user_agent = url.match?(/reddit/) ? "RSSr v1.0 (by #{ENV.fetch("REDDIT_USERNAME")})" : "linux:RSSr:1.0"
    { "User-agent" => user_agent }
  end

  def load_response
    @response = HTTParty.get(url, header: headers, verify: false)
  rescue StandardError => e
    errors.add(:base, e.message)
  end
end
