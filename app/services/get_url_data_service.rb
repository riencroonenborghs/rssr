# frozen_string_literal: true

class GetUrlDataService
  include Base

  attr_reader :url, :data

  def initialize(url:)
    @url = url
  end

  def call
    load_response
    return unless success?

    @data = response.body
  end

  private

  attr_reader :response

  def headers
    { "User-agent" => "linux:RSSr:1.0" }
  end

  def load_response
    @response = HTTParty.get(url, header: headers, verify: false)
  rescue StandardError => e
    errors.add(:base, e.message)
  end
end
