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

    parse_response
  end

  private

  def send_request
    request_headers = { "User-Agent" => "linux:Bootlegger:v1.0" }
    @response = HTTParty.get(@url, headers: request_headers, verify: false)
  rescue StandardError => e
    errors.add(:base, e.message)
  end

  def parse_response
    if @response.success?
      @headers = @response.headers
      @data = @response.body
      return
    end

    errors.add(:base, "Could not get url data: #{@response.code} #{@response.body}")
  end
end
